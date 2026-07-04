#!/usr/bin/env python3
"""Validate the FRP hardware sensitivity cost profile v1.

This validator is intentionally strict. It checks the canonical profile
identity, coefficient coverage and order, provenance resolution, scenario
vectors, bounds, validation contracts, repository path references, and the
self-authenticated SHA-256 digest.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import sys
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence


SCHEMA = "frp.benchmark.hardware_sensitivity_cost_profile.v1"
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
PROFILE_NAME = "literature_anchored_cmos45_sensitivity_v1"
PROFILE_ROLE = "hardware_informed_sensitivity"
PROFILE_STATUS = "reference_sensitivity_profile"
BASELINE_PROFILE = "unit_event_cost_v1"
BASELINE_RESULT = (
    "benchmarks/architecture_comparison/results/"
    "reference_comparison_seed_76.json"
)
PROVENANCE_MAP = (
    "benchmarks/architecture_comparison/calibration/"
    "coefficient_provenance_map_v1.md"
)

SCENARIO_ORDER = [
    "lower_bound",
    "nominal",
    "upper_bound",
]

COEFFICIENT_ORDER = [
    "encoded_bit_toggle",
    "clocked_state_bit",
    "register_write_bit",
    "comparison_event",
    "control_event",
    "queue_read",
    "queue_write",
    "lut_read_32",
    "fixed_point_multiply_32x32",
    "fixed_point_accumulate_64",
    "fixed_point_add_32",
    "fixed_point_compare_32",
]

EXPECTED_EVENT_FIELDS = {
    "encoded_bit_toggle": "encoded_bit_toggles",
    "clocked_state_bit": "clocked_state_bits",
    "register_write_bit": "register_write_bits",
    "comparison_event": "comparison_events",
    "control_event": "control_events",
    "queue_read": "queue_reads",
    "queue_write": "queue_writes",
    "lut_read_32": "lut_reads_32",
    "fixed_point_multiply_32x32": "fixed_point_multiplies_32x32",
    "fixed_point_accumulate_64": "fixed_point_accumulates_64",
    "fixed_point_add_32": "fixed_point_adds_32",
    "fixed_point_compare_32": "fixed_point_compares_32",
}

EXPECTED_BOUNDS = {
    "encoded_bit_toggle": (0.0078125, 0.03125, 0.125),
    "clocked_state_bit": (0.015625, 0.0625, 0.25),
    "register_write_bit": (0.03125, 0.125, 0.5),
    "comparison_event": (0.125, 0.5, 2.0),
    "control_event": (0.25, 1.0, 8.0),
    "queue_read": (1.0, 5.0, 30.0),
    "queue_write": (1.5, 7.5, 40.0),
    "lut_read_32": (20.0, 50.0, 100.0),
    "fixed_point_multiply_32x32": (20.0, 30.0, 40.0),
    "fixed_point_accumulate_64": (1.5, 2.0, 4.0),
    "fixed_point_add_32": (0.5, 1.0, 2.0),
    "fixed_point_compare_32": (0.5, 1.0, 2.0),
}

EXPECTED_BASIS_TYPES = {
    "encoded_bit_toggle": "implementation_assumption",
    "clocked_state_bit": "implementation_assumption",
    "register_write_bit": "implementation_assumption",
    "comparison_event": "implementation_assumption",
    "control_event": "implementation_assumption",
    "queue_read": "implementation_assumption",
    "queue_write": "implementation_assumption",
    "lut_read_32": "derived_from_literature_anchor",
    "fixed_point_multiply_32x32": "literature_anchor",
    "fixed_point_accumulate_64": "derived_from_literature_anchor",
    "fixed_point_add_32": "literature_anchor",
    "fixed_point_compare_32": "implementation_assumption",
}

EXPECTED_UNCERTAINTY = {
    "encoded_bit_toggle": "high",
    "clocked_state_bit": "high",
    "register_write_bit": "high",
    "comparison_event": "high",
    "control_event": "high",
    "queue_read": "high",
    "queue_write": "high",
    "lut_read_32": "high",
    "fixed_point_multiply_32x32": "medium",
    "fixed_point_accumulate_64": "medium",
    "fixed_point_add_32": "low",
    "fixed_point_compare_32": "high",
}

EXPECTED_REFERENCE_KEYS = {
    "encoded_bit_toggle": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "clocked_state_bit": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "register_write_bit": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "comparison_event": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "control_event": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "queue_read": "HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY",
    "queue_write": "HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY",
    "lut_read_32": "HOROWITZ_ISSCC_2014_8KB_CACHE_64BIT_ACCESS",
    "fixed_point_multiply_32x32": "HOROWITZ_ISSCC_2014_32BIT_INT_MULT",
    "fixed_point_accumulate_64": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "fixed_point_add_32": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "fixed_point_compare_32": "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
}

REFERENCE_ORDER = [
    "HOROWITZ_ISSCC_2014_32BIT_INT_ADD",
    "HOROWITZ_ISSCC_2014_32BIT_INT_MULT",
    "HOROWITZ_ISSCC_2014_8KB_CACHE_64BIT_ACCESS",
    "HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY",
]

ALLOWED_BASIS_TYPES = {
    "literature_anchor",
    "derived_from_literature_anchor",
    "implementation_assumption",
    "eda_measurement",
    "silicon_measurement",
}

ALLOWED_UNCERTAINTY_CLASSES = {
    "low",
    "medium",
    "high",
}

REQUIRED_COEFFICIENT_FIELDS = {
    "event_field",
    "cost_class",
    "lower_bound",
    "nominal_weight",
    "upper_bound",
    "basis_type",
    "reference_key",
    "reference",
    "source_value",
    "source_unit",
    "technology_node_nm",
    "voltage_v",
    "implementation_assumption",
    "derivation_rule",
    "uncertainty_class",
}

EXPECTED_ROOT_FIELDS = {
    "schema",
    "suite_name",
    "profile_name",
    "profile_role",
    "profile_status",
    "baseline_profile",
    "baseline_result",
    "provenance_map",
    "normalization_reference",
    "reference_basis",
    "scenario_order",
    "coefficient_order",
    "coefficients",
    "scenario_vectors",
    "evaluation_contract",
    "validation_contract",
    "digest_contract",
    "cost_profile_sha256",
}


class ProfileValidationError(ValueError):
    """Raised when the hardware sensitivity profile violates its contract."""


def fail(message: str) -> NoReturn:
    raise ProfileValidationError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def is_finite_number(value: Any) -> bool:
    return (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and math.isfinite(float(value))
    )


def require_finite_number(value: Any, path: str) -> float:
    require(
        is_finite_number(value),
        f"{path} must be a finite number",
    )
    return float(value)


def require_nonempty_string(value: Any, path: str) -> str:
    require(
        isinstance(value, str) and value.strip() != "",
        f"{path} must be a non-empty string",
    )
    return value


def reject_nonfinite_constant(token: str) -> NoReturn:
    fail(
        "non-finite JSON numeric constant is forbidden: "
        f"{token}"
    )


def load_profile(path: Path) -> dict[str, Any]:
    require(
        path.is_file(),
        f"profile file not found: {path}",
    )

    try:
        value = json.loads(
            path.read_text(encoding="utf-8"),
            parse_constant=reject_nonfinite_constant,
        )
    except ProfileValidationError:
        raise
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"unable to load profile JSON: {exc}")

    require(
        isinstance(value, dict),
        "profile root must be a JSON object",
    )

    return value


def canonical_profile_digest(
    profile: Mapping[str, Any],
) -> str:
    payload = dict(profile)

    require(
        "cost_profile_sha256" in payload,
        "cost_profile_sha256 is missing",
    )

    del payload["cost_profile_sha256"]

    try:
        canonical = json.dumps(
            payload,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
            allow_nan=False,
        ).encode("utf-8")
    except (TypeError, ValueError) as exc:
        fail(f"profile cannot be canonicalized: {exc}")

    return hashlib.sha256(canonical).hexdigest()


def refresh_profile_digest(
    profile: dict[str, Any],
) -> None:
    profile["cost_profile_sha256"] = (
        canonical_profile_digest(profile)
    )


def validate_identity(
    profile: Mapping[str, Any],
) -> None:
    require(
        set(profile.keys()) == EXPECTED_ROOT_FIELDS,
        "profile root fields do not match "
        "the canonical v1 contract",
    )

    require(
        profile["schema"] == SCHEMA,
        f"schema must be {SCHEMA}",
    )

    require(
        profile["suite_name"] == SUITE_NAME,
        f"suite_name must be {SUITE_NAME}",
    )

    require(
        profile["profile_name"] == PROFILE_NAME,
        f"profile_name must be {PROFILE_NAME}",
    )

    require(
        profile["profile_role"] == PROFILE_ROLE,
        f"profile_role must be {PROFILE_ROLE}",
    )

    require(
        profile["profile_status"] == PROFILE_STATUS,
        f"profile_status must be {PROFILE_STATUS}",
    )

    require(
        profile["baseline_profile"] == BASELINE_PROFILE,
        f"baseline_profile must be {BASELINE_PROFILE}",
    )

    require(
        profile["baseline_result"] == BASELINE_RESULT,
        f"baseline_result must be {BASELINE_RESULT}",
    )

    require(
        profile["provenance_map"] == PROVENANCE_MAP,
        f"provenance_map must be {PROVENANCE_MAP}",
    )


def validate_normalization_reference(
    profile: Mapping[str, Any],
) -> None:
    normalization = profile["normalization_reference"]

    require(
        isinstance(normalization, dict),
        "normalization_reference must be an object",
    )

    expected_fields = {
        "primitive",
        "normalized_weight",
        "reference_energy_value",
        "reference_energy_unit",
        "reference_technology_node_nm",
        "reference_voltage_v",
        "reference_key",
    }

    require(
        set(normalization.keys()) == expected_fields,
        "normalization_reference fields do not "
        "match the canonical contract",
    )

    require(
        normalization["primitive"]
        == "32-bit integer addition",
        "normalization primitive mismatch",
    )

    normalized_weight = require_finite_number(
        normalization["normalized_weight"],
        "normalization_reference.normalized_weight",
    )

    reference_energy = require_finite_number(
        normalization["reference_energy_value"],
        "normalization_reference.reference_energy_value",
    )

    require(
        normalized_weight == 1.0,
        "normalization weight must be 1.0",
    )

    require(
        reference_energy == 0.1,
        "normalization reference energy must be 0.1 pJ",
    )

    require(
        normalization["reference_energy_unit"] == "pJ",
        "normalization energy unit must be pJ",
    )

    require(
        normalization["reference_technology_node_nm"] == 45,
        "normalization technology node must be 45 nm",
    )

    require(
        normalization["reference_voltage_v"] is None,
        "normalization reference_voltage_v must be null",
    )

    require(
        normalization["reference_key"]
        == REFERENCE_ORDER[0],
        "normalization reference key mismatch",
    )


def validate_reference_basis(
    profile: Mapping[str, Any],
) -> set[str]:
    basis = profile["reference_basis"]

    require(
        isinstance(basis, list),
        "reference_basis must be an array",
    )

    require(
        len(basis) == len(REFERENCE_ORDER),
        "reference_basis must contain exactly four records",
    )

    keys: list[str] = []

    for index, record in enumerate(basis):
        path = f"reference_basis[{index}]"

        require(
            isinstance(record, dict),
            f"{path} must be an object",
        )

        key = require_nonempty_string(
            record.get("reference_key"),
            f"{path}.reference_key",
        )

        keys.append(key)

        require(
            record.get("doi")
            == "10.1109/ISSCC.2014.6757323",
            f"{path}.doi mismatch",
        )

        require(
            record.get("technology_node_nm") == 45,
            f"{path}.technology_node_nm must be 45",
        )

        require(
            record.get("approximate") is True,
            f"{path}.approximate must be true",
        )

    require(
        keys == REFERENCE_ORDER,
        "reference_basis reference_key order mismatch",
    )

    require(
        len(set(keys)) == len(keys),
        "reference_basis contains duplicate reference keys",
    )

    by_key = {
        record["reference_key"]: record
        for record in basis
    }

    require(
        by_key[REFERENCE_ORDER[0]][
            "reference_energy_value"
        ] == 0.1,
        "32-bit add anchor must be 0.1 pJ",
    )

    require(
        by_key[REFERENCE_ORDER[0]][
            "reference_energy_unit"
        ] == "pJ",
        "32-bit add anchor unit must be pJ",
    )

    require(
        by_key[REFERENCE_ORDER[1]][
            "reference_energy_value"
        ] == 3.0,
        "32-bit multiply anchor must be 3.0 pJ",
    )

    require(
        by_key[REFERENCE_ORDER[1]][
            "reference_energy_unit"
        ] == "pJ",
        "32-bit multiply anchor unit must be pJ",
    )

    require(
        by_key[REFERENCE_ORDER[2]][
            "reference_energy_value"
        ] == 10.0,
        "8 KB cache anchor must be 10.0 pJ",
    )

    require(
        by_key[REFERENCE_ORDER[2]][
            "reference_energy_unit"
        ] == "pJ",
        "8 KB cache anchor unit must be pJ",
    )

    require(
        by_key[REFERENCE_ORDER[3]][
            "reference_energy_value"
        ] is None,
        "qualitative memory hierarchy anchor "
        "energy value must be null",
    )

    require(
        by_key[REFERENCE_ORDER[3]][
            "reference_energy_unit"
        ] is None,
        "qualitative memory hierarchy anchor "
        "energy unit must be null",
    )

    return set(keys)


def validate_orders(
    profile: Mapping[str, Any],
) -> None:
    require(
        profile["scenario_order"] == SCENARIO_ORDER,
        "scenario_order mismatch",
    )

    require(
        profile["coefficient_order"]
        == COEFFICIENT_ORDER,
        "coefficient_order mismatch",
    )


def validate_coefficients(
    profile: Mapping[str, Any],
    reference_keys: set[str],
) -> None:
    coefficients = profile["coefficients"]

    require(
        isinstance(coefficients, dict),
        "coefficients must be an object",
    )

    require(
        list(coefficients.keys()) == COEFFICIENT_ORDER,
        "coefficient object order mismatch",
    )

    for cost_class in COEFFICIENT_ORDER:
        record = coefficients[cost_class]
        path = f"coefficients.{cost_class}"

        require(
            isinstance(record, dict),
            f"{path} must be an object",
        )

        require(
            set(record.keys())
            == REQUIRED_COEFFICIENT_FIELDS,
            f"{path} fields do not match "
            "the canonical contract",
        )

        require(
            record["event_field"]
            == EXPECTED_EVENT_FIELDS[cost_class],
            f"{path}.event_field mismatch",
        )

        require(
            record["cost_class"] == cost_class,
            f"{path}.cost_class mismatch",
        )

        lower = require_finite_number(
            record["lower_bound"],
            f"{path}.lower_bound",
        )

        nominal = require_finite_number(
            record["nominal_weight"],
            f"{path}.nominal_weight",
        )

        upper = require_finite_number(
            record["upper_bound"],
            f"{path}.upper_bound",
        )

        require(
            0.0 <= lower <= nominal <= upper,
            f"{path} violates "
            "0 <= lower <= nominal <= upper",
        )

        (
            expected_lower,
            expected_nominal,
            expected_upper,
        ) = EXPECTED_BOUNDS[cost_class]

        require(
            lower == expected_lower,
            f"{path}.lower_bound differs "
            "from the provenance map",
        )

        require(
            nominal == expected_nominal,
            f"{path}.nominal_weight differs "
            "from the provenance map",
        )

        require(
            upper == expected_upper,
            f"{path}.upper_bound differs "
            "from the provenance map",
        )

        basis_type = record["basis_type"]

        require(
            basis_type in ALLOWED_BASIS_TYPES,
            f"{path}.basis_type is not allowed",
        )

        require(
            basis_type
            == EXPECTED_BASIS_TYPES[cost_class],
            f"{path}.basis_type differs "
            "from the provenance map",
        )

        uncertainty = record["uncertainty_class"]

        require(
            uncertainty
            in ALLOWED_UNCERTAINTY_CLASSES,
            f"{path}.uncertainty_class is not allowed",
        )

        require(
            uncertainty
            == EXPECTED_UNCERTAINTY[cost_class],
            f"{path}.uncertainty_class differs "
            "from the provenance map",
        )

        reference_key = require_nonempty_string(
            record["reference_key"],
            f"{path}.reference_key",
        )

        require(
            reference_key in reference_keys,
            f"{path}.reference_key does not resolve",
        )

        require(
            reference_key
            == EXPECTED_REFERENCE_KEYS[cost_class],
            f"{path}.reference_key differs "
            "from the provenance map",
        )

        require_nonempty_string(
            record["reference"],
            f"{path}.reference",
        )

        require(
            record["technology_node_nm"] == 45,
            f"{path}.technology_node_nm must be 45",
        )

        voltage = record["voltage_v"]

        require(
            voltage is None
            or (
                is_finite_number(voltage)
                and float(voltage) > 0.0
            ),
            f"{path}.voltage_v must be null "
            "or a positive finite number",
        )

        require_nonempty_string(
            record["source_unit"],
            f"{path}.source_unit",
        )

        require_nonempty_string(
            record["implementation_assumption"],
            f"{path}.implementation_assumption",
        )

        require_nonempty_string(
            record["derivation_rule"],
            f"{path}.derivation_rule",
        )

        source_value = record["source_value"]

        require(
            source_value is None
            or is_finite_number(source_value),
            f"{path}.source_value must be null or finite",
        )


def validate_scenario_vectors(
    profile: Mapping[str, Any],
) -> None:
    coefficients = profile["coefficients"]
    vectors = profile["scenario_vectors"]

    require(
        isinstance(vectors, dict),
        "scenario_vectors must be an object",
    )

    require(
        list(vectors.keys()) == SCENARIO_ORDER,
        "scenario_vectors order mismatch",
    )

    field_by_scenario = {
        "lower_bound": "lower_bound",
        "nominal": "nominal_weight",
        "upper_bound": "upper_bound",
    }

    for scenario in SCENARIO_ORDER:
        vector = vectors[scenario]
        path = f"scenario_vectors.{scenario}"

        require(
            isinstance(vector, dict),
            f"{path} must be an object",
        )

        require(
            list(vector.keys()) == COEFFICIENT_ORDER,
            f"{path} coefficient order mismatch",
        )

        coefficient_field = (
            field_by_scenario[scenario]
        )

        for cost_class in COEFFICIENT_ORDER:
            value = require_finite_number(
                vector[cost_class],
                f"{path}.{cost_class}",
            )

            expected = float(
                coefficients[cost_class][
                    coefficient_field
                ]
            )

            require(
                value == expected,
                f"{path}.{cost_class} does not match "
                f"coefficients.{cost_class}."
                f"{coefficient_field}",
            )


def validate_evaluation_contract(
    profile: Mapping[str, Any],
) -> None:
    contract = profile["evaluation_contract"]

    require(
        isinstance(contract, dict),
        "evaluation_contract must be an object",
    )

    require(
        contract.get("execute_architectures_once")
        is True,
        "evaluation_contract.execute_architectures_once "
        "must be true",
    )

    require(
        contract.get("preserve_raw_event_traces")
        is True,
        "evaluation_contract.preserve_raw_event_traces "
        "must be true",
    )

    require(
        contract.get(
            "apply_same_scenario_vector_to_all_architectures"
        )
        is True,
        "evaluation_contract."
        "apply_same_scenario_vector_to_all_architectures "
        "must be true",
    )

    require(
        contract.get("scenario_result_order")
        == SCENARIO_ORDER,
        "evaluation_contract.scenario_result_order "
        "mismatch",
    )

    require(
        contract.get("thermal_profile")
        == "common_rc_thermal_proxy_v1",
        "evaluation_contract.thermal_profile mismatch",
    )

    require(
        contract.get("winner_assertions") == [],
        "evaluation_contract.winner_assertions "
        "must be empty",
    )


def validate_validation_contract(
    profile: Mapping[str, Any],
) -> None:
    contract = profile["validation_contract"]

    require(
        isinstance(contract, dict),
        "validation_contract must be an object",
    )

    required_true_fields = [
        "require_exact_coefficient_order",
        "require_exact_scenario_order",
        "require_nonnegative_weights",
        "require_lower_le_nominal_le_upper",
        "require_provenance_for_every_coefficient",
        "require_same_workload_digest",
        "require_same_architecture_result_digests",
        "require_same_raw_event_traces",
        "require_deterministic_profile_digest",
        "require_deterministic_package_digest",
        "require_byte_identical_repeated_generation",
    ]

    require(
        contract.get("required_cost_class_count") == 12,
        "validation_contract.required_cost_class_count "
        "must be 12",
    )

    for field in required_true_fields:
        require(
            contract.get(field) is True,
            f"validation_contract.{field} must be true",
        )

    semantic_completion_ratio = (
        require_finite_number(
            contract.get(
                "require_semantic_completion_ratio"
            ),
            "validation_contract."
            "require_semantic_completion_ratio",
        )
    )

    semantic_output_match = (
        require_finite_number(
            contract.get(
                "require_semantic_output_match"
            ),
            "validation_contract."
            "require_semantic_output_match",
        )
    )

    require(
        semantic_completion_ratio == 1.0,
        "validation_contract."
        "require_semantic_completion_ratio must be 1.0",
    )

    require(
        semantic_output_match == 1.0,
        "validation_contract."
        "require_semantic_output_match must be 1.0",
    )

    require(
        contract.get(
            "require_frp_actual_direct_events"
        )
        == 0,
        "validation_contract."
        "require_frp_actual_direct_events must be 0",
    )

    require(
        contract.get(
            "require_frp_reserved_state_events"
        )
        == 0,
        "validation_contract."
        "require_frp_reserved_state_events must be 0",
    )

    require(
        contract.get(
            "require_frp_queue_overflow_events"
        )
        == 0,
        "validation_contract."
        "require_frp_queue_overflow_events must be 0",
    )

    require(
        contract.get(
            "require_frp_pending_route_count_final"
        )
        == 0,
        "validation_contract."
        "require_frp_pending_route_count_final must be 0",
    )

    require(
        contract.get("winner_assertions") == [],
        "validation_contract.winner_assertions "
        "must be empty",
    )


def validate_digest_contract(
    profile: Mapping[str, Any],
) -> None:
    contract = profile["digest_contract"]

    require(
        isinstance(contract, dict),
        "digest_contract must be an object",
    )

    require(
        contract.get("algorithm") == "sha256",
        "digest_contract.algorithm must be sha256",
    )

    require(
        contract.get("canonicalization")
        == (
            "json.dumps(sort_keys=True,"
            "separators=(',',':'),"
            "ensure_ascii=False,allow_nan=False)"
        ),
        "digest_contract.canonicalization mismatch",
    )

    require(
        contract.get("excluded_field")
        == "cost_profile_sha256",
        "digest_contract.excluded_field mismatch",
    )


def validate_repository_paths(
    profile: Mapping[str, Any],
    repository_root: Path | None,
) -> None:
    if repository_root is None:
        return

    baseline_path = (
        repository_root
        / str(profile["baseline_result"])
    )

    provenance_path = (
        repository_root
        / str(profile["provenance_map"])
    )

    require(
        baseline_path.is_file(),
        "baseline result path does not exist: "
        f"{baseline_path}",
    )

    require(
        provenance_path.is_file(),
        "provenance map path does not exist: "
        f"{provenance_path}",
    )


def validate_digest(
    profile: Mapping[str, Any],
) -> str:
    recorded = require_nonempty_string(
        profile["cost_profile_sha256"],
        "cost_profile_sha256",
    )

    require(
        len(recorded) == 64,
        "cost_profile_sha256 must contain "
        "64 hexadecimal characters",
    )

    require(
        all(
            character in "0123456789abcdef"
            for character in recorded
        ),
        "cost_profile_sha256 must be "
        "lowercase hexadecimal",
    )

    recomputed = canonical_profile_digest(profile)

    require(
        recorded == recomputed,
        "cost_profile_sha256 mismatch: "
        f"recorded={recorded} "
        f"recomputed={recomputed}",
    )

    return recomputed


def validate_profile(
    profile: Mapping[str, Any],
    repository_root: Path | None = None,
) -> dict[str, Any]:
    validate_identity(profile)
    validate_normalization_reference(profile)

    reference_keys = validate_reference_basis(profile)

    validate_orders(profile)

    validate_coefficients(
        profile,
        reference_keys,
    )

    validate_scenario_vectors(profile)
    validate_evaluation_contract(profile)
    validate_validation_contract(profile)
    validate_digest_contract(profile)

    validate_repository_paths(
        profile,
        repository_root,
    )

    digest = validate_digest(profile)

    return {
        "status": "PASS",
        "schema": profile["schema"],
        "profile_name": profile["profile_name"],
        "coefficient_count": len(
            profile["coefficient_order"]
        ),
        "scenario_order": list(
            profile["scenario_order"]
        ),
        "reference_count": len(
            profile["reference_basis"]
        ),
        "cost_profile_sha256": digest,
        "baseline_result": profile["baseline_result"],
        "provenance_map": profile["provenance_map"],
    }


def expect_validation_failure(
    name: str,
    profile: dict[str, Any],
    repository_root: Path | None,
    expected_fragment: str,
) -> str:
    try:
        validate_profile(
            profile,
            repository_root=repository_root,
        )
    except ProfileValidationError as exc:
        message = str(exc)

        require(
            expected_fragment in message,
            f"self-test {name} failed "
            f"for unexpected reason: {message}",
        )

        return name

    fail(f"self-test {name} did not fail")


def run_self_test(
    profile: dict[str, Any],
    repository_root: Path | None,
) -> dict[str, Any]:
    validate_profile(
        profile,
        repository_root=repository_root,
    )

    completed: list[str] = []

    bad_bounds = copy.deepcopy(profile)

    bad_bounds[
        "coefficients"
    ][
        "fixed_point_add_32"
    ][
        "lower_bound"
    ] = 2.5

    refresh_profile_digest(bad_bounds)

    completed.append(
        expect_validation_failure(
            "reject_invalid_bounds",
            bad_bounds,
            repository_root,
            "0 <= lower <= nominal <= upper",
        )
    )

    bad_reference = copy.deepcopy(profile)

    bad_reference[
        "coefficients"
    ][
        "queue_read"
    ][
        "reference_key"
    ] = "MISSING_REFERENCE"

    refresh_profile_digest(bad_reference)

    completed.append(
        expect_validation_failure(
            "reject_unresolved_reference",
            bad_reference,
            repository_root,
            "reference_key does not resolve",
        )
    )

    bad_vector = copy.deepcopy(profile)

    bad_vector[
        "scenario_vectors"
    ][
        "nominal"
    ][
        "control_event"
    ] = 2.0

    refresh_profile_digest(bad_vector)

    completed.append(
        expect_validation_failure(
            "reject_scenario_vector_mismatch",
            bad_vector,
            repository_root,
            (
                "does not match "
                "coefficients.control_event.nominal_weight"
            ),
        )
    )

    bad_winner_policy = copy.deepcopy(profile)

    bad_winner_policy[
        "evaluation_contract"
    ][
        "winner_assertions"
    ] = [
        "frp_must_rank_first"
    ]

    refresh_profile_digest(bad_winner_policy)

    completed.append(
        expect_validation_failure(
            "reject_winner_assertion",
            bad_winner_policy,
            repository_root,
            "winner_assertions must be empty",
        )
    )

    bad_order = copy.deepcopy(profile)

    bad_order["coefficient_order"] = list(
        reversed(COEFFICIENT_ORDER)
    )

    refresh_profile_digest(bad_order)

    completed.append(
        expect_validation_failure(
            "reject_coefficient_order_change",
            bad_order,
            repository_root,
            "coefficient_order mismatch",
        )
    )

    bad_digest = copy.deepcopy(profile)

    bad_digest["cost_profile_sha256"] = (
        "0" * 64
    )

    completed.append(
        expect_validation_failure(
            "reject_digest_mismatch",
            bad_digest,
            repository_root,
            "cost_profile_sha256 mismatch",
        )
    )

    return {
        "status": "PASS",
        "self_test_count": len(completed),
        "self_tests": completed,
    }


def format_text(
    result: Mapping[str, Any],
) -> str:
    if "self_tests" in result:
        lines = [
            (
                "hardware sensitivity profile "
                "validator self-test: PASS"
            ),
            (
                "self_test_count="
                f"{result['self_test_count']}"
            ),
        ]

        lines.extend(
            f"PASS {name}"
            for name in result["self_tests"]
        )

        return "\n".join(lines)

    return "\n".join(
        [
            (
                "hardware sensitivity profile "
                "validation: PASS"
            ),
            f"schema={result['schema']}",
            f"profile_name={result['profile_name']}",
            (
                "coefficient_count="
                f"{result['coefficient_count']}"
            ),
            (
                "scenario_order="
                f"{','.join(result['scenario_order'])}"
            ),
            (
                "reference_count="
                f"{result['reference_count']}"
            ),
            (
                "cost_profile_sha256="
                f"{result['cost_profile_sha256']}"
            ),
            (
                "baseline_result="
                f"{result['baseline_result']}"
            ),
            (
                "provenance_map="
                f"{result['provenance_map']}"
            ),
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    script_dir = Path(__file__).resolve().parent

    default_profile = (
        script_dir
        / "profiles"
        / "hardware_sensitivity_cost_profile_v1.json"
    )

    parser = argparse.ArgumentParser(
        description=(
            "Validate the FRP hardware sensitivity "
            "cost profile v1."
        )
    )

    parser.add_argument(
        "--profile",
        default=str(default_profile),
        help=(
            "Path to "
            "hardware_sensitivity_cost_profile_v1.json"
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run validator positive and negative "
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
            "Skip existence checks for the declared "
            "baseline result and provenance map."
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
        profile = load_profile(profile_path)

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

    except ProfileValidationError as exc:
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
                "hardware sensitivity profile "
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

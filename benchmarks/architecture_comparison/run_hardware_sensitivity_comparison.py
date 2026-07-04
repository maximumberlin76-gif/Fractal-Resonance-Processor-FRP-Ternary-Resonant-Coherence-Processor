#!/usr/bin/env python3
"""Run the FRP hardware-informed comparative sensitivity analysis.

The runner executes the four architecture references exactly once, binds the
resulting architecture digests and raw event traces to the canonical unit-event
baseline, and then evaluates the same raw traces under the lower-bound,
nominal, and upper-bound hardware sensitivity vectors.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from itertools import combinations
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence

from common_cost_model import (
    COST_CLASSES,
    CostModelError,
    NormalizedCostProfile,
    build_cost_profile_package,
    profile_from_package as cost_profile_from_package,
)
from common_thermal_model import (
    ThermalModelError,
    ThermalProxyProfile,
    load_thermal_profile,
)
from run_architecture_comparison import (
    ARCHITECTURE_ORDER,
    FRP_REFERENCE_VERSION,
    SUITE_NAME,
    ArchitectureComparisonError,
    all_finite_numbers,
    build_default_thermal_profile,
    canonical_json_bytes,
    cost_profile_metadata,
    evaluate_architecture,
    extract_cycle_event_trace,
    load_or_build_workload,
    run_architecture_references,
    sha256_hex,
    thermal_profile_metadata,
    validate_architecture_result,
    write_json,
)
from validate_hardware_sensitivity_profile import (
    ProfileValidationError,
    load_profile as load_hardware_sensitivity_profile,
    validate_profile as validate_hardware_sensitivity_profile,
)


SENSITIVITY_SCHEMA = (
    "frp.benchmark.hardware_sensitivity_comparison.v1"
)

SELF_TEST_SCHEMA = (
    "frp.benchmark.hardware_sensitivity_comparison.self_test.v1"
)

BENCHMARK_KIND = "hardware_informed_sensitivity_matrix"

QUALIFICATION_POLICY = "integrity_only_no_winner_assertions"

SCENARIO_ORDER = (
    "lower_bound",
    "nominal",
    "upper_bound",
)

EXPECTED_BASELINE_SCHEMA = (
    "frp.benchmark.architecture_comparison.v1"
)

EXPECTED_PROFILE_SCHEMA = (
    "frp.benchmark.hardware_sensitivity_cost_profile.v1"
)

EXPECTED_PROFILE_NAME = (
    "literature_anchored_cmos45_sensitivity_v1"
)

SCENARIO_COST_UNIT = (
    "normalized_32bit_add_equivalent"
)

PAIRWISE_CLASSIFICATIONS = {
    "stable_lower_cost",
    "stable_higher_cost",
    "crosses_within_sensitivity_range",
}

FLOAT_ABS_TOLERANCE = 1e-12

SCRIPT_DIR = Path(__file__).resolve().parent

REPOSITORY_ROOT = SCRIPT_DIR.parents[1]

DEFAULT_HARDWARE_SENSITIVITY_PROFILE = (
    SCRIPT_DIR
    / "profiles"
    / "hardware_sensitivity_cost_profile_v1.json"
)


class HardwareSensitivityComparisonError(ValueError):
    """Raised when the sensitivity comparison contract is violated."""


def fail(message: str) -> NoReturn:
    raise HardwareSensitivityComparisonError(message)


def require(
    condition: bool,
    message: str,
) -> None:
    if not condition:
        fail(message)


def load_json_object(
    path: Path,
) -> dict[str, Any]:
    require(
        path.is_file(),
        f"JSON file not found: {path}",
    )

    try:
        value = json.loads(
            path.read_text(
                encoding="utf-8"
            )
        )
    except OSError as exc:
        fail(
            "unable to read JSON file: "
            f"{path}: {exc}"
        )
    except json.JSONDecodeError as exc:
        fail(
            "invalid JSON file: "
            f"{path}: {exc}"
        )

    require(
        isinstance(value, dict),
        "JSON file must contain an object: "
        f"{path}",
    )

    return value


def architecture_index(
    architecture_id: str,
) -> int:
    try:
        return ARCHITECTURE_ORDER.index(
            architecture_id
        )
    except ValueError as exc:
        raise HardwareSensitivityComparisonError(
            "unknown architecture_id: "
            f"{architecture_id}"
        ) from exc


def absolute_repository_path(
    relative_path: str,
) -> Path:
    path = (
        REPOSITORY_ROOT
        / relative_path
    ).resolve()

    require(
        path == REPOSITORY_ROOT
        or REPOSITORY_ROOT in path.parents,
        "declared repository path escapes "
        "repository root: "
        f"{relative_path}",
    )

    return path


def recompute_embedded_digest(
    package: Mapping[str, Any],
    *,
    digest_field: str,
) -> str:
    require(
        digest_field in package,
        f"missing digest field: {digest_field}",
    )

    payload = dict(package)

    recorded = payload.pop(
        digest_field
    )

    require(
        isinstance(recorded, str)
        and len(recorded) == 64
        and all(
            character
            in "0123456789abcdef"
            for character in recorded
        ),
        f"invalid {digest_field}",
    )

    recomputed = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    require(
        recorded == recomputed,
        f"{digest_field} mismatch: "
        f"recorded={recorded} "
        f"recomputed={recomputed}",
    )

    return recomputed


def load_and_validate_sensitivity_profile(
    path: Path,
) -> tuple[
    dict[str, Any],
    dict[str, Any],
]:
    profile = (
        load_hardware_sensitivity_profile(
            path
        )
    )

    validation = (
        validate_hardware_sensitivity_profile(
            profile,
            repository_root=REPOSITORY_ROOT,
        )
    )

    require(
        validation["status"] == "PASS",
        "hardware sensitivity profile "
        "validation did not pass",
    )

    require(
        profile["schema"]
        == EXPECTED_PROFILE_SCHEMA,
        "hardware sensitivity profile "
        "schema mismatch",
    )

    require(
        profile["profile_name"]
        == EXPECTED_PROFILE_NAME,
        "hardware sensitivity profile "
        "name mismatch",
    )

    require(
        tuple(
            profile["scenario_order"]
        )
        == SCENARIO_ORDER,
        "hardware sensitivity scenario "
        "order mismatch",
    )

    require(
        profile[
            "evaluation_contract"
        ][
            "winner_assertions"
        ]
        == [],
        "hardware sensitivity evaluation "
        "winner_assertions must be empty",
    )

    require(
        profile[
            "validation_contract"
        ][
            "winner_assertions"
        ]
        == [],
        "hardware sensitivity validation "
        "winner_assertions must be empty",
    )

    return (
        profile,
        validation,
    )


def load_and_validate_baseline_package(
    profile: Mapping[str, Any],
) -> tuple[
    Path,
    dict[str, Any],
    dict[str, Any],
]:
    baseline_relative = str(
        profile["baseline_result"]
    )

    baseline_path = (
        absolute_repository_path(
            baseline_relative
        )
    )

    baseline = load_json_object(
        baseline_path
    )

    checks = {
        "schema_match": (
            baseline.get("schema")
            == EXPECTED_BASELINE_SCHEMA
        ),
        "architecture_order_match": (
            baseline.get(
                "architecture_order"
            )
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "baseline_profile_match": (
            baseline.get(
                "cost_profile",
                {},
            ).get(
                "profile_name"
            )
            == profile[
                "baseline_profile"
            ]
        ),
        "integrity_status_pass": (
            baseline.get(
                "integrity",
                {},
            ).get(
                "status"
            )
            == "PASS"
        ),
        "qualification_status_pass": (
            baseline.get(
                "qualification",
                {},
            ).get(
                "status"
            )
            == "PASS"
        ),
        "winner_assertions_empty": (
            baseline.get(
                "qualification",
                {},
            ).get(
                "winner_assertions"
            )
            == []
        ),
    }

    require(
        all(
            checks.values()
        ),
        "canonical unit-event baseline "
        "package contract failed: "
        + ", ".join(
            name
            for name, passed
            in checks.items()
            if not passed
        ),
    )

    digest = recompute_embedded_digest(
        baseline,
        digest_field=(
            "comparison_package_sha256"
        ),
    )

    checks[
        "comparison_package_digest_valid"
    ] = True

    architectures = baseline.get(
        "architectures"
    )

    require(
        isinstance(
            architectures,
            list,
        ),
        "baseline architectures must "
        "be an array",
    )

    require(
        [
            row.get(
                "architecture_id"
            )
            for row in architectures
        ]
        == list(
            ARCHITECTURE_ORDER
        ),
        "baseline architecture evaluation "
        "order mismatch",
    )

    architecture_digests: dict[
        str,
        str,
    ] = {}

    for row in architectures:
        architecture_id = str(
            row["architecture_id"]
        )

        digest_value = row.get(
            "architecture_result_sha256"
        )

        require(
            isinstance(
                digest_value,
                str,
            )
            and len(
                digest_value
            )
            == 64,
            "invalid baseline architecture "
            "result digest for "
            f"{architecture_id}",
        )

        architecture_digests[
            architecture_id
        ] = digest_value

    binding = {
        "status": "PASS",
        "baseline_result": (
            baseline_relative
        ),
        "baseline_schema": (
            baseline["schema"]
        ),
        "baseline_workload_sha256": (
            baseline[
                "workload_sha256"
            ]
        ),
        "baseline_cost_profile": (
            baseline[
                "cost_profile"
            ][
                "profile_name"
            ]
        ),
        "baseline_comparison_package_sha256": (
            digest
        ),
        "architecture_result_sha256": (
            architecture_digests
        ),
        "checks": checks,
    }

    return (
        baseline_path,
        baseline,
        binding,
    )


def build_raw_trace_ledger(
    architecture_results: Sequence[
        Mapping[str, Any]
    ],
) -> list[dict[str, Any]]:
    ledger: list[
        dict[str, Any]
    ] = []

    for result in architecture_results:
        architecture_id = str(
            result[
                "architecture_id"
            ]
        )

        event_trace = (
            extract_cycle_event_trace(
                result
            )
        )

        raw_event_totals = dict(
            result[
                "raw_event_totals"
            ]
        )

        specific = dict(
            result[
                "architecture_specific_metrics"
            ]
        )

        comparison_metrics = dict(
            result[
                "comparison_metrics"
            ]
        )

        ledger.append(
            {
                "architecture_id": (
                    architecture_id
                ),
                "architecture_name": (
                    result[
                        "architecture_name"
                    ]
                ),
                "architecture_result_sha256": (
                    result[
                        "architecture_result_sha256"
                    ]
                ),
                "workload_sha256": (
                    result[
                        "workload_sha256"
                    ]
                ),
                "processor_cycles": (
                    raw_event_totals[
                        "processor_cycles"
                    ]
                ),
                "raw_event_totals": (
                    raw_event_totals
                ),
                "raw_event_totals_sha256": (
                    sha256_hex(
                        canonical_json_bytes(
                            raw_event_totals
                        )
                    )
                ),
                "raw_event_trace_sha256": (
                    sha256_hex(
                        canonical_json_bytes(
                            event_trace
                        )
                    )
                ),
                "comparison_metrics": (
                    comparison_metrics
                ),
                "architecture_specific_metrics": (
                    specific
                ),
            }
        )

    require(
        [
            row[
                "architecture_id"
            ]
            for row in ledger
        ]
        == list(
            ARCHITECTURE_ORDER
        ),
        "raw trace ledger architecture "
        "order mismatch",
    )

    return ledger


def raw_trace_set_sha256(
    ledger: Sequence[
        Mapping[str, Any]
    ],
) -> str:
    payload = [
        {
            "architecture_id": (
                row[
                    "architecture_id"
                ]
            ),
            "architecture_result_sha256": (
                row[
                    "architecture_result_sha256"
                ]
            ),
            "raw_event_totals_sha256": (
                row[
                    "raw_event_totals_sha256"
                ]
            ),
            "raw_event_trace_sha256": (
                row[
                    "raw_event_trace_sha256"
                ]
            ),
        }
        for row in ledger
    ]

    return sha256_hex(
        canonical_json_bytes(
            payload
        )
    )


def validate_baseline_binding(
    *,
    baseline: Mapping[str, Any],
    workload_sha256: str,
    raw_trace_ledger: Sequence[
        Mapping[str, Any]
    ],
) -> dict[str, Any]:
    baseline_by_id = {
        str(
            row[
                "architecture_id"
            ]
        ): row
        for row
        in baseline[
            "architectures"
        ]
    }

    checks = {
        "same_workload_digest": (
            baseline[
                "workload_sha256"
            ]
            == workload_sha256
        ),
        "architecture_order_match": (
            [
                row[
                    "architecture_id"
                ]
                for row
                in raw_trace_ledger
            ]
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "architecture_result_digests_match": (
            all(
                row[
                    "architecture_result_sha256"
                ]
                == baseline_by_id[
                    str(
                        row[
                            "architecture_id"
                        ]
                    )
                ][
                    "architecture_result_sha256"
                ]
                for row
                in raw_trace_ledger
            )
        ),
    }

    require(
        all(
            checks.values()
        ),
        "current architecture execution "
        "does not bind to canonical baseline: "
        + ", ".join(
            name
            for name, passed
            in checks.items()
            if not passed
        ),
    )

    return {
        "status": "PASS",
        "checks": checks,
    }


def build_scenario_cost_profile(
    hardware_profile: Mapping[
        str,
        Any,
    ],
    scenario_id: str,
) -> NormalizedCostProfile:
    require(
        scenario_id
        in SCENARIO_ORDER,
        "unknown sensitivity scenario: "
        f"{scenario_id}",
    )

    vector = hardware_profile[
        "scenario_vectors"
    ][
        scenario_id
    ]

    require(
        list(
            vector.keys()
        )
        == list(
            hardware_profile[
                "coefficient_order"
            ]
        ),
        "scenario vector coefficient "
        "order mismatch: "
        f"{scenario_id}",
    )

    require(
        list(
            vector.keys()
        )
        == list(
            COST_CLASSES
        ),
        "scenario vector common cost-class "
        "order mismatch: "
        f"{scenario_id}",
    )

    package = (
        build_cost_profile_package(
            profile_name=(
                f"{hardware_profile['profile_name']}"
                f"::{scenario_id}"
            ),
            cost_unit=(
                SCENARIO_COST_UNIT
            ),
            costs=vector,
        )
    )

    return cost_profile_from_package(
        package
    )


def compact_scenario_evaluation(
    evaluation: Mapping[
        str,
        Any,
    ],
    *,
    raw_event_trace_sha256_value: str,
) -> dict[str, Any]:
    return {
        "architecture_id": (
            evaluation[
                "architecture_id"
            ]
        ),
        "architecture_name": (
            evaluation[
                "architecture_name"
            ]
        ),
        "architecture_result_sha256": (
            evaluation[
                "architecture_result_sha256"
            ]
        ),
        "workload_sha256": (
            evaluation[
                "workload_sha256"
            ]
        ),
        "raw_event_trace_sha256": (
            raw_event_trace_sha256_value
        ),
        "comparison_metrics": dict(
            evaluation[
                "comparison_metrics"
            ]
        ),
        "normalized_cost": dict(
            evaluation[
                "normalized_cost"
            ]
        ),
        "thermal_proxy": dict(
            evaluation[
                "thermal_proxy"
            ]
        ),
        "integrity": dict(
            evaluation[
                "integrity"
            ]
        ),
    }


def energy_relation(
    left: float,
    right: float,
) -> str:
    if math.isclose(
        left,
        right,
        rel_tol=0.0,
        abs_tol=(
            FLOAT_ABS_TOLERANCE
        ),
    ):
        return "equal_cost"

    if left < right:
        return "lower_cost"

    return "higher_cost"


def build_scenario_ranking(
    comparison_matrix: Sequence[
        Mapping[str, Any]
    ],
) -> dict[str, Any]:
    by_id = {
        str(
            row[
                "architecture_id"
            ]
        ): row
        for row
        in comparison_matrix
    }

    require(
        list(
            by_id.keys()
        )
        == list(
            ARCHITECTURE_ORDER
        ),
        "scenario comparison matrix "
        "architecture order mismatch",
    )

    ordered_ids = sorted(
        ARCHITECTURE_ORDER,
        key=lambda architecture_id: (
            float(
                by_id[
                    architecture_id
                ][
                    "total_normalized_energy"
                ]
            ),
            architecture_index(
                architecture_id
            ),
        ),
    )

    ranked_rows = [
        {
            "rank": index + 1,
            "architecture_id": (
                architecture_id
            ),
            "total_normalized_energy": (
                by_id[
                    architecture_id
                ][
                    "total_normalized_energy"
                ]
            ),
            "normalized_energy_per_completed_command": (
                by_id[
                    architecture_id
                ][
                    "normalized_energy_per_completed_command"
                ]
            ),
            "peak_temperature_proxy": (
                by_id[
                    architecture_id
                ][
                    "peak_temperature_proxy"
                ]
            ),
            "final_temperature_proxy": (
                by_id[
                    architecture_id
                ][
                    "final_temperature_proxy"
                ]
            ),
        }
        for index, architecture_id
        in enumerate(
            ordered_ids
        )
    ]

    energies = [
        float(
            row[
                "total_normalized_energy"
            ]
        )
        for row
        in ranked_rows
    ]

    ties_present = any(
        math.isclose(
            energies[index],
            energies[index + 1],
            rel_tol=0.0,
            abs_tol=(
                FLOAT_ABS_TOLERANCE
            ),
        )
        for index
        in range(
            len(energies) - 1
        )
    )

    return {
        "basis": (
            "ascending_total_normalized_energy"
        ),
        "architecture_order": list(
            ordered_ids
        ),
        "ties_present": (
            ties_present
        ),
        "rows": ranked_rows,
    }


def build_scenario_result(
    *,
    scenario_id: str,
    hardware_profile: Mapping[
        str,
        Any,
    ],
    architecture_results: Sequence[
        Mapping[str, Any]
    ],
    raw_trace_ledger: Sequence[
        Mapping[str, Any]
    ],
    thermal_profile: ThermalProxyProfile,
) -> dict[str, Any]:
    cost_profile = (
        build_scenario_cost_profile(
            hardware_profile,
            scenario_id,
        )
    )

    ledger_by_id = {
        str(
            row[
                "architecture_id"
            ]
        ): row
        for row
        in raw_trace_ledger
    }

    evaluations: list[
        dict[str, Any]
    ] = []

    comparison_matrix: list[
        dict[str, Any]
    ] = []

    for result in architecture_results:
        architecture_id = str(
            result[
                "architecture_id"
            ]
        )

        (
            evaluation,
            comparison_row,
        ) = evaluate_architecture(
            result,
            cost_profile=(
                cost_profile
            ),
            thermal_profile=(
                thermal_profile
            ),
        )

        evaluations.append(
            compact_scenario_evaluation(
                evaluation,
                raw_event_trace_sha256_value=(
                    ledger_by_id[
                        architecture_id
                    ][
                        "raw_event_trace_sha256"
                    ]
                ),
            )
        )

        comparison_matrix.append(
            comparison_row
        )

    scenario_vector = {
        cost_class: float(
            hardware_profile[
                "scenario_vectors"
            ][
                scenario_id
            ][
                cost_class
            ]
        )
        for cost_class
        in hardware_profile[
            "coefficient_order"
        ]
    }

    integrity_checks = {
        "architecture_order_match": (
            [
                row[
                    "architecture_id"
                ]
                for row
                in evaluations
            ]
            == list(
                ARCHITECTURE_ORDER
            )
            and
            [
                row[
                    "architecture_id"
                ]
                for row
                in comparison_matrix
            ]
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "same_architecture_result_digests": (
            all(
                row[
                    "architecture_result_sha256"
                ]
                == ledger_by_id[
                    str(
                        row[
                            "architecture_id"
                        ]
                    )
                ][
                    "architecture_result_sha256"
                ]
                for row
                in evaluations
            )
        ),
        "same_raw_event_trace_digests": (
            all(
                row[
                    "raw_event_trace_sha256"
                ]
                == ledger_by_id[
                    str(
                        row[
                            "architecture_id"
                        ]
                    )
                ][
                    "raw_event_trace_sha256"
                ]
                for row
                in evaluations
            )
        ),
        "same_workload_digest": (
            len(
                {
                    row[
                        "workload_sha256"
                    ]
                    for row
                    in evaluations
                }
            )
            == 1
        ),
        "same_cost_profile_digest": (
            all(
                row[
                    "normalized_cost"
                ][
                    "cost_profile_sha256"
                ]
                == cost_profile.cost_profile_sha256
                for row
                in evaluations
            )
        ),
        "same_thermal_profile_digest": (
            all(
                row[
                    "thermal_proxy"
                ][
                    "thermal_profile_sha256"
                ]
                == thermal_profile.thermal_profile_sha256
                for row
                in evaluations
            )
        ),
        "event_trace_closure": (
            all(
                row[
                    "integrity"
                ][
                    "event_trace_closure"
                ]
                for row
                in evaluations
            )
        ),
        "cost_cycle_count_closure": (
            all(
                row[
                    "integrity"
                ][
                    "cost_cycle_count_closure"
                ]
                for row
                in evaluations
            )
        ),
        "thermal_cycle_count_closure": (
            all(
                row[
                    "integrity"
                ][
                    "thermal_cycle_count_closure"
                ]
                for row
                in evaluations
            )
        ),
        "finite_numeric_values": (
            all_finite_numbers(
                {
                    "evaluations": (
                        evaluations
                    ),
                    "comparison_matrix": (
                        comparison_matrix
                    ),
                }
            )
        ),
        "semantic_completion_ratio_one": (
            all(
                row[
                    "semantic_completion_ratio"
                ]
                == 1.0
                for row
                in comparison_matrix
            )
        ),
        "semantic_output_match_one": (
            all(
                row[
                    "semantic_output_match"
                ]
                == 1.0
                for row
                in comparison_matrix
            )
        ),
    }

    ranking = build_scenario_ranking(
        comparison_matrix
    )

    return {
        "scenario_id": scenario_id,
        "scenario_vector": (
            scenario_vector
        ),
        "scenario_vector_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    scenario_vector
                )
            )
        ),
        "cost_profile": (
            cost_profile_metadata(
                cost_profile
            )
        ),
        "scenario_cost_profile_sha256": (
            cost_profile.cost_profile_sha256
        ),
        "architectures": (
            evaluations
        ),
        "comparison_matrix": (
            comparison_matrix
        ),
        "ranking": ranking,
        "integrity": {
            "status": (
                "PASS"
                if all(
                    integrity_checks.values()
                )
                else "FAIL"
            ),
            "checks": (
                integrity_checks
            ),
        },
    }


def build_pairwise_stability(
    scenarios: Sequence[
        Mapping[str, Any]
    ],
) -> list[dict[str, Any]]:
    scenario_by_id = {
        str(
            scenario[
                "scenario_id"
            ]
        ): scenario
        for scenario
        in scenarios
    }

    energies: dict[
        str,
        dict[str, float],
    ] = {}

    for scenario_id in SCENARIO_ORDER:
        matrix = (
            scenario_by_id[
                scenario_id
            ][
                "comparison_matrix"
            ]
        )

        energies[
            scenario_id
        ] = {
            str(
                row[
                    "architecture_id"
                ]
            ): float(
                row[
                    "total_normalized_energy"
                ]
            )
            for row
            in matrix
        }

    results: list[
        dict[str, Any]
    ] = []

    for (
        left_id,
        right_id,
    ) in combinations(
        ARCHITECTURE_ORDER,
        2,
    ):
        relations = {
            scenario_id: (
                energy_relation(
                    energies[
                        scenario_id
                    ][
                        left_id
                    ],
                    energies[
                        scenario_id
                    ][
                        right_id
                    ],
                )
            )
            for scenario_id
            in SCENARIO_ORDER
        }

        relation_values = list(
            relations.values()
        )

        if all(
            value == "lower_cost"
            for value
            in relation_values
        ):
            classification = (
                "stable_lower_cost"
            )

        elif all(
            value == "higher_cost"
            for value
            in relation_values
        ):
            classification = (
                "stable_higher_cost"
            )

        else:
            classification = (
                "crosses_within_sensitivity_range"
            )

        results.append(
            {
                "left_architecture_id": (
                    left_id
                ),
                "right_architecture_id": (
                    right_id
                ),
                "interpretation_basis": (
                    "left_architecture_"
                    "total_normalized_energy_"
                    "relative_to_right"
                ),
                "scenario_relations": (
                    relations
                ),
                "classification": (
                    classification
                ),
            }
        )

    return results


def build_ranking_stability(
    scenarios: Sequence[
        Mapping[str, Any]
    ],
) -> dict[str, Any]:
    scenario_rankings = {
        str(
            scenario[
                "scenario_id"
            ]
        ): list(
            scenario[
                "ranking"
            ][
                "architecture_order"
            ]
        )
        for scenario
        in scenarios
    }

    ranking_sequences = [
        tuple(
            scenario_rankings[
                scenario_id
            ]
        )
        for scenario_id
        in SCENARIO_ORDER
    ]

    ranking_stable = (
        len(
            set(
                ranking_sequences
            )
        )
        == 1
    )

    pairwise = (
        build_pairwise_stability(
            scenarios
        )
    )

    return {
        "ranking_basis": (
            "ascending_total_normalized_energy"
        ),
        "scenario_rankings": (
            scenario_rankings
        ),
        "ranking_stable": (
            ranking_stable
        ),
        "ranking_sensitive": (
            not ranking_stable
        ),
        "pairwise_stability": (
            pairwise
        ),
    }


def scenario_architecture_digest_map(
    scenario: Mapping[
        str,
        Any,
    ],
) -> dict[str, str]:
    return {
        str(
            row[
                "architecture_id"
            ]
        ): str(
            row[
                "architecture_result_sha256"
            ]
        )
        for row
        in scenario[
            "architectures"
        ]
    }


def scenario_raw_trace_digest_map(
    scenario: Mapping[
        str,
        Any,
    ],
) -> dict[str, str]:
    return {
        str(
            row[
                "architecture_id"
            ]
        ): str(
            row[
                "raw_event_trace_sha256"
            ]
        )
        for row
        in scenario[
            "architectures"
        ]
    }


def validate_scenario_vectors_exact(
    *,
    profile: Mapping[
        str,
        Any,
    ],
    scenarios: Sequence[
        Mapping[str, Any]
    ],
) -> bool:
    by_id = {
        str(
            scenario[
                "scenario_id"
            ]
        ): scenario
        for scenario
        in scenarios
    }

    return all(
        by_id[
            scenario_id
        ][
            "scenario_vector"
        ]
        == {
            cost_class: float(
                profile[
                    "scenario_vectors"
                ][
                    scenario_id
                ][
                    cost_class
                ]
            )
            for cost_class
            in profile[
                "coefficient_order"
            ]
        }
        for scenario_id
        in SCENARIO_ORDER
    )


def validate_frp_invariants(
    raw_trace_ledger: Sequence[
        Mapping[str, Any]
    ],
) -> dict[str, bool]:
    by_id = {
        str(
            row[
                "architecture_id"
            ]
        ): row
        for row
        in raw_trace_ledger
    }

    frp_specific = (
        by_id[
            "frp_v1_7_0_quantized_shadow"
        ][
            "architecture_specific_metrics"
        ]
    )

    return {
        "frp_actual_direct_events_zero": (
            frp_specific[
                "actual_direct_events"
            ]
            == 0
        ),
        "frp_reserved_state_events_zero": (
            frp_specific[
                "reserved_state_events"
            ]
            == 0
        ),
        "frp_queue_overflow_events_zero": (
            frp_specific[
                "queue_overflow_events"
            ]
            == 0
        ),
        "frp_pending_route_count_final_zero": (
            frp_specific[
                "pending_route_count_final"
            ]
            == 0
        ),
        "frp_requested_direct_events_equal_prevented": (
            frp_specific[
                "requested_direct_events"
            ]
            == frp_specific[
                "prevented_direct_events"
            ]
        ),
        "frp_neutral_insertions_equal_neutral_routed": (
            frp_specific[
                "neutral_insertions"
            ]
            == frp_specific[
                "neutral_routed_events"
            ]
        ),
    }


def build_hardware_sensitivity_package(
    *,
    workload_package: Mapping[
        str,
        Any,
    ],
    hardware_profile: Mapping[
        str,
        Any,
    ],
    profile_validation: Mapping[
        str,
        Any,
    ],
    baseline: Mapping[
        str,
        Any,
    ],
    baseline_binding_metadata: Mapping[
        str,
        Any,
    ],
    thermal_profile: ThermalProxyProfile,
    frp_scheduler: str,
) -> dict[str, Any]:
    workload_sha256 = str(
        workload_package[
            "workload_sha256"
        ]
    )

    architecture_results = (
        run_architecture_references(
            workload_package,
            frp_scheduler=(
                frp_scheduler
            ),
        )
    )

    require(
        [
            str(
                result[
                    "architecture_id"
                ]
            )
            for result
            in architecture_results
        ]
        == list(
            ARCHITECTURE_ORDER
        ),
        "architecture execution "
        "order mismatch",
    )

    for result in architecture_results:
        validate_architecture_result(
            result,
            workload_sha256=(
                workload_sha256
            ),
        )

    ledger = build_raw_trace_ledger(
        architecture_results
    )

    trace_set_digest = (
        raw_trace_set_sha256(
            ledger
        )
    )

    current_baseline_binding = (
        validate_baseline_binding(
            baseline=baseline,
            workload_sha256=(
                workload_sha256
            ),
            raw_trace_ledger=(
                ledger
            ),
        )
    )

    scenarios = [
        build_scenario_result(
            scenario_id=(
                scenario_id
            ),
            hardware_profile=(
                hardware_profile
            ),
            architecture_results=(
                architecture_results
            ),
            raw_trace_ledger=(
                ledger
            ),
            thermal_profile=(
                thermal_profile
            ),
        )
        for scenario_id
        in SCENARIO_ORDER
    ]

    ranking_stability = (
        build_ranking_stability(
            scenarios
        )
    )

    ledger_architecture_digests = {
        str(
            row[
                "architecture_id"
            ]
        ): str(
            row[
                "architecture_result_sha256"
            ]
        )
        for row
        in ledger
    }

    ledger_trace_digests = {
        str(
            row[
                "architecture_id"
            ]
        ): str(
            row[
                "raw_event_trace_sha256"
            ]
        )
        for row
        in ledger
    }

    scenario_ids = [
        str(
            row[
                "scenario_id"
            ]
        )
        for row
        in scenarios
    ]

    scenario_architecture_maps = [
        scenario_architecture_digest_map(
            scenario
        )
        for scenario
        in scenarios
    ]

    scenario_trace_maps = [
        scenario_raw_trace_digest_map(
            scenario
        )
        for scenario
        in scenarios
    ]

    integrity_checks = {
        "profile_validation_pass": (
            profile_validation[
                "status"
            ]
            == "PASS"
        ),
        "baseline_package_contract_pass": (
            baseline_binding_metadata[
                "status"
            ]
            == "PASS"
        ),
        "current_execution_baseline_binding_pass": (
            current_baseline_binding[
                "status"
            ]
            == "PASS"
        ),
        "architecture_order_match": (
            [
                row[
                    "architecture_id"
                ]
                for row
                in ledger
            ]
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "same_workload_digest": (
            all(
                row[
                    "workload_sha256"
                ]
                == workload_sha256
                for row
                in ledger
            )
            and baseline[
                "workload_sha256"
            ]
            == workload_sha256
        ),
        "architecture_result_digests_match_baseline": (
            all(
                row[
                    "architecture_result_sha256"
                ]
                == baseline_binding_metadata[
                    "architecture_result_sha256"
                ][
                    str(
                        row[
                            "architecture_id"
                        ]
                    )
                ]
                for row
                in ledger
            )
        ),
        "scenario_order_match": (
            scenario_ids
            == list(
                SCENARIO_ORDER
            )
        ),
        "scenario_count_three": (
            len(
                scenarios
            )
            == 3
        ),
        "all_scenario_integrity_pass": (
            all(
                scenario[
                    "integrity"
                ][
                    "status"
                ]
                == "PASS"
                and all(
                    scenario[
                        "integrity"
                    ][
                        "checks"
                    ].values()
                )
                for scenario
                in scenarios
            )
        ),
        "same_architecture_result_digests_all_scenarios": (
            all(
                mapping
                == ledger_architecture_digests
                for mapping
                in scenario_architecture_maps
            )
        ),
        "same_raw_event_trace_digests_all_scenarios": (
            all(
                mapping
                == ledger_trace_digests
                for mapping
                in scenario_trace_maps
            )
        ),
        "same_thermal_profile_digest_all_scenarios": (
            all(
                all(
                    row[
                        "thermal_proxy"
                    ][
                        "thermal_profile_sha256"
                    ]
                    == thermal_profile.thermal_profile_sha256
                    for row
                    in scenario[
                        "architectures"
                    ]
                )
                for scenario
                in scenarios
            )
        ),
        "scenario_vectors_exact": (
            validate_scenario_vectors_exact(
                profile=(
                    hardware_profile
                ),
                scenarios=(
                    scenarios
                ),
            )
        ),
        "scenario_cost_profiles_unique": (
            len(
                {
                    scenario[
                        "scenario_cost_profile_sha256"
                    ]
                    for scenario
                    in scenarios
                }
            )
            == 3
        ),
        "ranking_analysis_complete": (
            set(
                ranking_stability[
                    "scenario_rankings"
                ]
            )
            == set(
                SCENARIO_ORDER
            )
        ),
        "pairwise_analysis_complete": (
            len(
                ranking_stability[
                    "pairwise_stability"
                ]
            )
            == 6
            and all(
                row[
                    "classification"
                ]
                in PAIRWISE_CLASSIFICATIONS
                for row
                in ranking_stability[
                    "pairwise_stability"
                ]
            )
        ),
        "finite_numeric_values": (
            all_finite_numbers(
                {
                    "raw_trace_ledger": (
                        ledger
                    ),
                    "scenarios": (
                        scenarios
                    ),
                    "ranking_stability": (
                        ranking_stability
                    ),
                }
            )
        ),
        "winner_assertions_absent": (
            hardware_profile[
                "evaluation_contract"
            ][
                "winner_assertions"
            ]
            == []
            and hardware_profile[
                "validation_contract"
            ][
                "winner_assertions"
            ]
            == []
        ),
    }

    frp_invariant_checks = (
        validate_frp_invariants(
            ledger
        )
    )

    qualification_checks = {
        "integrity_status_pass": (
            all(
                integrity_checks.values()
            )
        ),
        "all_architectures_completed_workload": (
            all(
                row[
                    "raw_event_totals"
                ][
                    "semantic_commands_issued"
                ]
                == workload_package[
                    "workload_profile"
                ][
                    "command_count"
                ]
                and row[
                    "raw_event_totals"
                ][
                    "semantic_commands_completed"
                ]
                == workload_package[
                    "workload_profile"
                ][
                    "command_count"
                ]
                for row
                in ledger
            )
        ),
        "semantic_completion_ratio_one_all": (
            all(
                row[
                    "comparison_metrics"
                ][
                    "semantic_completion_ratio"
                ]
                == 1.0
                for row
                in ledger
            )
        ),
        "semantic_output_match_one_all": (
            all(
                row[
                    "comparison_metrics"
                ][
                    "semantic_output_match"
                ]
                == 1.0
                for row
                in ledger
            )
        ),
        "same_raw_traces_used_for_all_scenarios": (
            integrity_checks[
                "same_raw_event_trace_digests_all_scenarios"
            ]
        ),
        "same_architecture_results_used_for_all_scenarios": (
            integrity_checks[
                "same_architecture_result_digests_all_scenarios"
            ]
        ),
        "scenario_vectors_global_and_exact": (
            integrity_checks[
                "scenario_vectors_exact"
            ]
        ),
        "no_winner_assertions": (
            integrity_checks[
                "winner_assertions_absent"
            ]
        ),
        **frp_invariant_checks,
    }

    digest_payload = {
        "schema": (
            SENSITIVITY_SCHEMA
        ),
        "suite_name": (
            SUITE_NAME
        ),
        "benchmark_kind": (
            BENCHMARK_KIND
        ),
        "frp_reference_version": (
            FRP_REFERENCE_VERSION
        ),
        "frp_scheduler": (
            frp_scheduler
        ),
        "architecture_order": list(
            ARCHITECTURE_ORDER
        ),
        "workload_profile": dict(
            workload_package[
                "workload_profile"
            ]
        ),
        "workload_sha256": (
            workload_sha256
        ),
        "hardware_sensitivity_profile": {
            "schema": (
                hardware_profile[
                    "schema"
                ]
            ),
            "profile_name": (
                hardware_profile[
                    "profile_name"
                ]
            ),
            "profile_role": (
                hardware_profile[
                    "profile_role"
                ]
            ),
            "profile_status": (
                hardware_profile[
                    "profile_status"
                ]
            ),
            "cost_profile_sha256": (
                hardware_profile[
                    "cost_profile_sha256"
                ]
            ),
            "baseline_profile": (
                hardware_profile[
                    "baseline_profile"
                ]
            ),
            "baseline_result": (
                hardware_profile[
                    "baseline_result"
                ]
            ),
            "provenance_map": (
                hardware_profile[
                    "provenance_map"
                ]
            ),
            "normalization_reference": dict(
                hardware_profile[
                    "normalization_reference"
                ]
            ),
            "scenario_order": list(
                hardware_profile[
                    "scenario_order"
                ]
            ),
            "coefficient_order": list(
                hardware_profile[
                    "coefficient_order"
                ]
            ),
        },
        "hardware_sensitivity_profile_sha256": (
            hardware_profile[
                "cost_profile_sha256"
            ]
        ),
        "profile_validation": dict(
            profile_validation
        ),
        "baseline_binding": {
            **dict(
                baseline_binding_metadata
            ),
            "current_execution": (
                current_baseline_binding
            ),
        },
        "thermal_profile": (
            thermal_profile_metadata(
                thermal_profile
            )
        ),
        "thermal_profile_sha256": (
            thermal_profile.thermal_profile_sha256
        ),
        "raw_trace_ledger": (
            ledger
        ),
        "raw_trace_set_sha256": (
            trace_set_digest
        ),
        "scenarios": (
            scenarios
        ),
        "ranking_stability": (
            ranking_stability
        ),
        "integrity": {
            "status": (
                "PASS"
                if all(
                    integrity_checks.values()
                )
                else "FAIL"
            ),
            "checks": (
                integrity_checks
            ),
        },
        "qualification": {
            "policy": (
                QUALIFICATION_POLICY
            ),
            "status": (
                "PASS"
                if all(
                    qualification_checks.values()
                )
                else "FAIL"
            ),
            "checks": (
                qualification_checks
            ),
            "winner_assertions": [],
        },
    }

    package = dict(
        digest_payload
    )

    package[
        "hardware_sensitivity_package_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            digest_payload
        )
    )

    return package


def build_default_inputs(
    *,
    workload_profile_path: Path | None,
    workload_package_path: Path | None,
    hardware_sensitivity_profile_path: Path,
    thermal_profile_path: Path | None,
) -> tuple[
    dict[str, Any],
    dict[str, Any],
    dict[str, Any],
    dict[str, Any],
    dict[str, Any],
    ThermalProxyProfile,
]:
    workload_package = (
        load_or_build_workload(
            workload_profile_path=(
                workload_profile_path
            ),
            workload_package_path=(
                workload_package_path
            ),
        )
    )

    (
        hardware_profile,
        profile_validation,
    ) = (
        load_and_validate_sensitivity_profile(
            hardware_sensitivity_profile_path
        )
    )

    (
        _,
        baseline,
        baseline_binding_metadata,
    ) = (
        load_and_validate_baseline_package(
            hardware_profile
        )
    )

    thermal_profile = (
        load_thermal_profile(
            thermal_profile_path
        )
        if thermal_profile_path
        is not None
        else build_default_thermal_profile()
    )

    return (
        workload_package,
        hardware_profile,
        profile_validation,
        baseline,
        baseline_binding_metadata,
        thermal_profile,
    )


def run_self_test(
    *,
    hardware_sensitivity_profile_path: Path,
) -> dict[str, Any]:
    (
        workload_package,
        hardware_profile,
        profile_validation,
        baseline,
        baseline_binding_metadata,
        thermal_profile,
    ) = build_default_inputs(
        workload_profile_path=None,
        workload_package_path=None,
        hardware_sensitivity_profile_path=(
            hardware_sensitivity_profile_path
        ),
        thermal_profile_path=None,
    )

    package_a = (
        build_hardware_sensitivity_package(
            workload_package=(
                workload_package
            ),
            hardware_profile=(
                hardware_profile
            ),
            profile_validation=(
                profile_validation
            ),
            baseline=(
                baseline
            ),
            baseline_binding_metadata=(
                baseline_binding_metadata
            ),
            thermal_profile=(
                thermal_profile
            ),
            frp_scheduler="7/1",
        )
    )

    package_b = (
        build_hardware_sensitivity_package(
            workload_package=(
                workload_package
            ),
            hardware_profile=(
                hardware_profile
            ),
            profile_validation=(
                profile_validation
            ),
            baseline=(
                baseline
            ),
            baseline_binding_metadata=(
                baseline_binding_metadata
            ),
            thermal_profile=(
                thermal_profile
            ),
            frp_scheduler="7/1",
        )
    )

    scenario_ids = [
        scenario[
            "scenario_id"
        ]
        for scenario
        in package_a[
            "scenarios"
        ]
    ]

    raw_digests = {
        row[
            "architecture_id"
        ]: row[
            "raw_event_trace_sha256"
        ]
        for row
        in package_a[
            "raw_trace_ledger"
        ]
    }

    checks = {
        "schema_correct": (
            package_a[
                "schema"
            ]
            == SENSITIVITY_SCHEMA
        ),
        "architecture_order_exact": (
            package_a[
                "architecture_order"
            ]
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "scenario_order_exact": (
            scenario_ids
            == list(
                SCENARIO_ORDER
            )
        ),
        "three_scenarios_present": (
            len(
                package_a[
                    "scenarios"
                ]
            )
            == 3
        ),
        "four_raw_architectures_present": (
            len(
                package_a[
                    "raw_trace_ledger"
                ]
            )
            == 4
        ),
        "profile_digest_preserved": (
            package_a[
                "hardware_sensitivity_profile_sha256"
            ]
            == hardware_profile[
                "cost_profile_sha256"
            ]
        ),
        "baseline_binding_pass": (
            package_a[
                "baseline_binding"
            ][
                "current_execution"
            ][
                "status"
            ]
            == "PASS"
        ),
        "integrity_status_pass": (
            package_a[
                "integrity"
            ][
                "status"
            ]
            == "PASS"
        ),
        "all_integrity_checks_pass": (
            all(
                package_a[
                    "integrity"
                ][
                    "checks"
                ].values()
            )
        ),
        "qualification_status_pass": (
            package_a[
                "qualification"
            ][
                "status"
            ]
            == "PASS"
        ),
        "all_qualification_checks_pass": (
            all(
                package_a[
                    "qualification"
                ][
                    "checks"
                ].values()
            )
        ),
        "no_winner_assertion_policy": (
            package_a[
                "qualification"
            ][
                "policy"
            ]
            == QUALIFICATION_POLICY
            and package_a[
                "qualification"
            ][
                "winner_assertions"
            ]
            == []
        ),
        "same_raw_trace_digests_all_scenarios": (
            all(
                {
                    row[
                        "architecture_id"
                    ]: row[
                        "raw_event_trace_sha256"
                    ]
                    for row
                    in scenario[
                        "architectures"
                    ]
                }
                == raw_digests
                for scenario
                in package_a[
                    "scenarios"
                ]
            )
        ),
        "scenario_vectors_exact": (
            package_a[
                "integrity"
            ][
                "checks"
            ][
                "scenario_vectors_exact"
            ]
        ),
        "scenario_cost_profile_digests_distinct": (
            len(
                {
                    scenario[
                        "scenario_cost_profile_sha256"
                    ]
                    for scenario
                    in package_a[
                        "scenarios"
                    ]
                }
            )
            == 3
        ),
        "ranking_analysis_complete": (
            len(
                package_a[
                    "ranking_stability"
                ][
                    "scenario_rankings"
                ]
            )
            == 3
        ),
        "pairwise_analysis_complete": (
            len(
                package_a[
                    "ranking_stability"
                ][
                    "pairwise_stability"
                ]
            )
            == 6
        ),
        "all_scenario_semantics_match": (
            all(
                row[
                    "semantic_output_match"
                ]
                == 1.0
                and row[
                    "semantic_completion_ratio"
                ]
                == 1.0
                for scenario
                in package_a[
                    "scenarios"
                ]
                for row
                in scenario[
                    "comparison_matrix"
                ]
            )
        ),
        "frp_direct_events_zero": (
            package_a[
                "qualification"
            ][
                "checks"
            ][
                "frp_actual_direct_events_zero"
            ]
        ),
        "frp_reserved_state_events_zero": (
            package_a[
                "qualification"
            ][
                "checks"
            ][
                "frp_reserved_state_events_zero"
            ]
        ),
        "frp_queue_overflow_events_zero": (
            package_a[
                "qualification"
            ][
                "checks"
            ][
                "frp_queue_overflow_events_zero"
            ]
        ),
        "frp_pending_route_count_final_zero": (
            package_a[
                "qualification"
            ][
                "checks"
            ][
                "frp_pending_route_count_final_zero"
            ]
        ),
        "finite_numeric_values": (
            all_finite_numbers(
                package_a
            )
        ),
        "deterministic_package_digest_repeat": (
            package_a[
                "hardware_sensitivity_package_sha256"
            ]
            == package_b[
                "hardware_sensitivity_package_sha256"
            ]
        ),
        "deterministic_package_byte_repeat": (
            canonical_json_bytes(
                package_a
            )
            == canonical_json_bytes(
                package_b
            )
        ),
        "package_digest_length_64": (
            len(
                package_a[
                    "hardware_sensitivity_package_sha256"
                ]
            )
            == 64
        ),
    }

    status = (
        "PASS"
        if all(
            checks.values()
        )
        else "FAIL"
    )

    return {
        "schema": (
            SELF_TEST_SCHEMA
        ),
        "status": status,
        "check_count": (
            len(
                checks
            )
        ),
        "checks": checks,
        "workload_sha256": (
            package_a[
                "workload_sha256"
            ]
        ),
        "hardware_sensitivity_profile_sha256": (
            package_a[
                "hardware_sensitivity_profile_sha256"
            ]
        ),
        "thermal_profile_sha256": (
            package_a[
                "thermal_profile_sha256"
            ]
        ),
        "raw_trace_set_sha256": (
            package_a[
                "raw_trace_set_sha256"
            ]
        ),
        "hardware_sensitivity_package_sha256": (
            package_a[
                "hardware_sensitivity_package_sha256"
            ]
        ),
        "qualification_status": (
            package_a[
                "qualification"
            ][
                "status"
            ]
        ),
        "ranking_stability": (
            package_a[
                "ranking_stability"
            ]
        ),
        "scenario_summaries": [
            {
                "scenario_id": (
                    scenario[
                        "scenario_id"
                    ]
                ),
                "scenario_cost_profile_sha256": (
                    scenario[
                        "scenario_cost_profile_sha256"
                    ]
                ),
                "ranking": (
                    scenario[
                        "ranking"
                    ][
                        "architecture_order"
                    ]
                ),
                "total_normalized_energy": {
                    row[
                        "architecture_id"
                    ]: row[
                        "total_normalized_energy"
                    ]
                    for row
                    in scenario[
                        "comparison_matrix"
                    ]
                },
            }
            for scenario
            in package_a[
                "scenarios"
            ]
        ],
    }


def print_text_result(
    result: Mapping[
        str,
        Any,
    ],
    *,
    self_test: bool,
) -> None:
    if self_test:
        print(
            "FRP HARDWARE SENSITIVITY "
            "COMPARISON SELF TEST"
        )

        print(
            f"status={result['status']}"
        )

        print(
            f"checks={result['check_count']}"
        )

        print(
            "workload_sha256="
            f"{result['workload_sha256']}"
        )

        print(
            "hardware_sensitivity_profile_sha256="
            f"{result['hardware_sensitivity_profile_sha256']}"
        )

        print(
            "hardware_sensitivity_package_sha256="
            f"{result['hardware_sensitivity_package_sha256']}"
        )

        print(
            "qualification_status="
            f"{result['qualification_status']}"
        )

        return

    print(
        "FRP HARDWARE SENSITIVITY "
        "COMPARISON"
    )

    print(
        f"schema={result['schema']}"
    )

    print(
        "workload_sha256="
        f"{result['workload_sha256']}"
    )

    print(
        "hardware_sensitivity_profile_sha256="
        f"{result['hardware_sensitivity_profile_sha256']}"
    )

    print(
        "thermal_profile_sha256="
        f"{result['thermal_profile_sha256']}"
    )

    print(
        "integrity_status="
        f"{result['integrity']['status']}"
    )

    print(
        "qualification_status="
        f"{result['qualification']['status']}"
    )

    print(
        "ranking_stable="
        f"{result['ranking_stability']['ranking_stable']}"
    )

    print(
        "ranking_sensitive="
        f"{result['ranking_stability']['ranking_sensitive']}"
    )

    print(
        "hardware_sensitivity_package_sha256="
        f"{result['hardware_sensitivity_package_sha256']}"
    )

    for scenario in result[
        "scenarios"
    ]:
        print()

        print(
            "scenario_id="
            f"{scenario['scenario_id']}"
        )

        print(
            "scenario_cost_profile_sha256="
            f"{scenario['scenario_cost_profile_sha256']}"
        )

        print(
            "ranking="
            + ",".join(
                scenario[
                    "ranking"
                ][
                    "architecture_order"
                ]
            )
        )

        for row in scenario[
            "comparison_matrix"
        ]:
            print(
                f"{row['architecture_id']}."
                "total_normalized_energy="
                f"{row['total_normalized_energy']}"
            )

            print(
                f"{row['architecture_id']}."
                "peak_temperature_proxy="
                f"{row['peak_temperature_proxy']}"
            )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Run the FRP hardware-informed "
            "sensitivity comparison over the "
            "same canonical raw architecture traces."
        )
    )

    parser.add_argument(
        "--workload-profile",
        type=Path,
        help=(
            "Optional workload profile JSON path. "
            "The canonical default profile is used "
            "when omitted."
        ),
    )

    parser.add_argument(
        "--workload-package",
        type=Path,
        help=(
            "Optional pre-generated workload package "
            "JSON path. The package must bind to the "
            "canonical unit-event baseline."
        ),
    )

    parser.add_argument(
        "--hardware-sensitivity-profile",
        type=Path,
        default=(
            DEFAULT_HARDWARE_SENSITIVITY_PROFILE
        ),
        help=(
            "Hardware sensitivity profile JSON path. "
            "Defaults to "
            "profiles/"
            "hardware_sensitivity_cost_profile_v1.json."
        ),
    )

    parser.add_argument(
        "--thermal-profile",
        type=Path,
        help=(
            "Optional common thermal proxy profile "
            "JSON path. The built-in "
            "common_rc_thermal_proxy_v1 profile "
            "is used when omitted."
        ),
    )

    parser.add_argument(
        "--frp-scheduler",
        choices=(
            "free",
            "7/1",
            "1/7",
        ),
        default="7/1",
        help=(
            "FRP M15 scheduler mode."
        ),
    )

    parser.add_argument(
        "--write",
        type=Path,
        help=(
            "Optional path for the complete "
            "sensitivity package JSON."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run deterministic end-to-end "
            "sensitivity self-tests."
        ),
    )

    parser.add_argument(
        "--output",
        choices=(
            "json",
            "text",
        ),
        default="json",
        help="Output format.",
    )

    return parser


def main(
    argv: Sequence[str] | None = None,
) -> int:
    args = build_parser().parse_args(
        argv
    )

    try:
        hardware_profile_path = (
            Path(
                args.hardware_sensitivity_profile
            )
            .expanduser()
            .resolve()
        )

        if args.self_test:
            result = run_self_test(
                hardware_sensitivity_profile_path=(
                    hardware_profile_path
                ),
            )

        else:
            (
                workload_package,
                hardware_profile,
                profile_validation,
                baseline,
                baseline_binding_metadata,
                thermal_profile,
            ) = build_default_inputs(
                workload_profile_path=(
                    args.workload_profile
                ),
                workload_package_path=(
                    args.workload_package
                ),
                hardware_sensitivity_profile_path=(
                    hardware_profile_path
                ),
                thermal_profile_path=(
                    args.thermal_profile
                ),
            )

            result = (
                build_hardware_sensitivity_package(
                    workload_package=(
                        workload_package
                    ),
                    hardware_profile=(
                        hardware_profile
                    ),
                    profile_validation=(
                        profile_validation
                    ),
                    baseline=(
                        baseline
                    ),
                    baseline_binding_metadata=(
                        baseline_binding_metadata
                    ),
                    thermal_profile=(
                        thermal_profile
                    ),
                    frp_scheduler=(
                        args.frp_scheduler
                    ),
                )
            )

        if args.write:
            write_json(
                args.write,
                result,
            )

        if args.output == "json":
            print(
                json.dumps(
                    result,
                    ensure_ascii=False,
                    sort_keys=True,
                    indent=2,
                    allow_nan=False,
                )
            )

        else:
            print_text_result(
                result,
                self_test=(
                    args.self_test
                ),
            )

        if args.self_test:
            return (
                0
                if result[
                    "status"
                ]
                == "PASS"
                else 1
            )

        return (
            0
            if result[
                "qualification"
            ][
                "status"
            ]
            == "PASS"
            else 1
        )

    except (
        HardwareSensitivityComparisonError,
        ProfileValidationError,
        ArchitectureComparisonError,
        CostModelError,
        ThermalModelError,
        OSError,
        ValueError,
        TypeError,
        KeyError,
        IndexError,
    ) as exc:
        raise SystemExit(
            "hardware sensitivity comparison "
            "error: "
            f"{exc}"
        ) from exc


if __name__ == "__main__":
    sys.exit(
        main()
    )

#!/usr/bin/env python3
"""Execute the FRP Comparative Architecture Benchmark Suite."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any, Mapping, Sequence

from binary_clock_gated_reference import (
    BinaryClockGatedError,
    execute_binary_clock_gated_reference,
)
from binary_synchronous_reference import (
    BinarySynchronousError,
    execute_binary_synchronous_reference,
)
from common_cost_model import (
    COST_CLASSES,
    EVENT_FIELDS,
    CostModelError,
    NormalizedCostProfile,
    build_cost_profile_package,
    calculate_trace_cost,
    load_cost_profile,
    profile_from_package as cost_profile_from_package,
)
from common_thermal_model import (
    ThermalModelError,
    ThermalProxyProfile,
    build_thermal_profile_package,
    calculate_thermal_trace,
    load_thermal_profile,
    profile_from_package as thermal_profile_from_package,
)
from common_workload import (
    WorkloadError,
    WorkloadProfile,
    build_workload_package,
    load_profile,
    validate_workload_package,
)
from direct_ternary_reference import (
    DirectTernaryError,
    execute_direct_ternary_reference,
)
from frp_v1_7_0_adapter import (
    DEFAULT_FRP_SCHEDULER,
    FRPAdapterError,
    execute_frp_v1_7_0_adapter,
)

COMPARISON_SCHEMA = "frp.benchmark.architecture_comparison.v1"
SELF_TEST_SCHEMA = "frp.benchmark.architecture_comparison.self_test.v1"
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
FRP_REFERENCE_VERSION = "1.7.0"
BENCHMARK_KIND = "comparative_architecture_matrix"
QUALIFICATION_POLICY = "integrity_only_no_winner_assertions"

ARCHITECTURE_ORDER = (
    "binary_synchronous_reference",
    "binary_clock_gated_reference",
    "direct_ternary_reference",
    "frp_v1_7_0_quantized_shadow",
)

COMPARISON_METRIC_FIELDS = (
    "semantic_completion_ratio",
    "semantic_output_match",
    "completion_ticks",
    "mean_latency_ticks",
    "p95_latency_ticks",
    "maximum_latency_ticks",
    "throughput_commands_per_tick",
    "logical_state_changes",
    "encoded_bit_toggles",
    "processor_cycles",
    "active_clocked_cycles",
    "active_clock_fraction",
)


class ArchitectureComparisonError(ValueError):
    """Raised when comparative execution or package integrity is invalid."""


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        allow_nan=False,
    ).encode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    path.write_text(
        json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            indent=2,
            allow_nan=False,
        )
        + "\n",
        encoding="utf-8",
    )


def load_json_object(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(
            path.read_text(
                encoding="utf-8"
            )
        )
    except OSError as exc:
        raise ArchitectureComparisonError(
            f"unable to read JSON file: {path}"
        ) from exc
    except json.JSONDecodeError as exc:
        raise ArchitectureComparisonError(
            f"invalid JSON file: {path}"
        ) from exc

    if not isinstance(value, dict):
        raise ArchitectureComparisonError(
            f"JSON file must contain an object: {path}"
        )

    return value


def build_default_cost_profile() -> NormalizedCostProfile:
    return cost_profile_from_package(
        build_cost_profile_package()
    )


def build_default_thermal_profile() -> ThermalProxyProfile:
    return thermal_profile_from_package(
        build_thermal_profile_package()
    )


def cost_profile_metadata(
    profile: NormalizedCostProfile,
) -> dict[str, Any]:
    return {
        "profile_name": profile.profile_name,
        "cost_unit": profile.cost_unit,
        "costs": {
            cost_class: float(
                profile.costs[cost_class]
            )
            for cost_class in COST_CLASSES
        },
    }


def thermal_profile_metadata(
    profile: ThermalProxyProfile,
) -> dict[str, Any]:
    return {
        "profile_name": profile.profile_name,
        "temperature_unit": profile.temperature_unit,
        "ambient_temperature_proxy": (
            profile.ambient_temperature_proxy
        ),
        "thermal_decay": profile.thermal_decay,
        "thermal_gain": profile.thermal_gain,
    }


def load_or_build_workload(
    *,
    workload_profile_path: Path | None,
    workload_package_path: Path | None,
) -> dict[str, Any]:
    if (
        workload_profile_path is not None
        and workload_package_path is not None
    ):
        raise ArchitectureComparisonError(
            "use either --workload-profile or "
            "--workload-package, not both"
        )

    if workload_package_path is not None:
        package = load_json_object(
            workload_package_path
        )

        validate_workload_package(
            package
        )

        return package

    profile = (
        load_profile(
            workload_profile_path
        )
        if workload_profile_path is not None
        else WorkloadProfile()
    )

    return build_workload_package(
        profile
    )


def run_architecture_references(
    workload_package: Mapping[str, Any],
    *,
    frp_scheduler: str,
) -> list[dict[str, Any]]:
    return [
        execute_binary_synchronous_reference(
            workload_package
        ),
        execute_binary_clock_gated_reference(
            workload_package
        ),
        execute_direct_ternary_reference(
            workload_package
        ),
        execute_frp_v1_7_0_adapter(
            workload_package,
            scheduler=frp_scheduler,
        ),
    ]


def validate_architecture_result(
    result: Mapping[str, Any],
    *,
    workload_sha256: str,
) -> None:
    architecture_id = result.get(
        "architecture_id"
    )

    if architecture_id not in ARCHITECTURE_ORDER:
        raise ArchitectureComparisonError(
            f"unexpected architecture_id: "
            f"{architecture_id}"
        )

    if (
        result.get("workload_sha256")
        != workload_sha256
    ):
        raise ArchitectureComparisonError(
            f"workload digest mismatch for "
            f"{architecture_id}"
        )

    result_digest = result.get(
        "architecture_result_sha256"
    )

    if (
        not isinstance(result_digest, str)
        or len(result_digest) != 64
    ):
        raise ArchitectureComparisonError(
            f"invalid architecture result digest "
            f"for {architecture_id}"
        )

    raw = result.get(
        "raw_event_totals"
    )

    metrics = result.get(
        "comparison_metrics"
    )

    specific = result.get(
        "architecture_specific_metrics"
    )

    if not isinstance(raw, Mapping):
        raise ArchitectureComparisonError(
            f"raw_event_totals missing for "
            f"{architecture_id}"
        )

    if not isinstance(metrics, Mapping):
        raise ArchitectureComparisonError(
            f"comparison_metrics missing for "
            f"{architecture_id}"
        )

    if not isinstance(specific, Mapping):
        raise ArchitectureComparisonError(
            f"architecture_specific_metrics missing "
            f"for {architecture_id}"
        )

    for field in COMPARISON_METRIC_FIELDS:
        if field not in metrics:
            raise ArchitectureComparisonError(
                f"missing comparison metric {field} "
                f"for {architecture_id}"
            )

    for event_field in EVENT_FIELDS:
        if event_field not in raw:
            raise ArchitectureComparisonError(
                f"missing raw event {event_field} "
                f"for {architecture_id}"
            )


def extract_cycle_event_trace(
    result: Mapping[str, Any],
) -> list[Mapping[str, Any]]:
    cycle_trace = result.get(
        "cycle_trace"
    )

    if not isinstance(cycle_trace, list):
        raise ArchitectureComparisonError(
            "architecture cycle_trace must be a list"
        )

    event_trace: list[Mapping[str, Any]] = []

    for index, row in enumerate(
        cycle_trace
    ):
        if not isinstance(row, Mapping):
            raise ArchitectureComparisonError(
                f"cycle_trace[{index}] must be "
                "an object"
            )

        cost_events = row.get(
            "cost_events"
        )

        if not isinstance(
            cost_events,
            Mapping,
        ):
            raise ArchitectureComparisonError(
                f"cycle_trace[{index}].cost_events "
                "must be an object"
            )

        event_trace.append(
            cost_events
        )

    return event_trace


def all_finite_numbers(
    value: Any,
) -> bool:
    if isinstance(value, bool):
        return True

    if isinstance(
        value,
        (int, float),
    ):
        return math.isfinite(
            float(value)
        )

    if isinstance(value, Mapping):
        return all(
            all_finite_numbers(item)
            for item in value.values()
        )

    if (
        isinstance(value, Sequence)
        and not isinstance(
            value,
            (
                str,
                bytes,
                bytearray,
            ),
        )
    ):
        return all(
            all_finite_numbers(item)
            for item in value
        )

    return True


def evaluate_architecture(
    result: Mapping[str, Any],
    *,
    cost_profile: NormalizedCostProfile,
    thermal_profile: ThermalProxyProfile,
) -> tuple[
    dict[str, Any],
    dict[str, Any],
]:
    architecture_id = str(
        result["architecture_id"]
    )

    event_trace = (
        extract_cycle_event_trace(
            result
        )
    )

    cost_result = calculate_trace_cost(
        event_trace,
        cost_profile,
    )

    thermal_result = (
        calculate_thermal_trace(
            cost_result[
                "cycle_normalized_energy"
            ],
            thermal_profile,
        )
    )

    raw = result[
        "raw_event_totals"
    ]

    metrics = result[
        "comparison_metrics"
    ]

    specific = result[
        "architecture_specific_metrics"
    ]

    expected_event_totals = {
        event_field: raw[event_field]
        for event_field in EVENT_FIELDS
    }

    processor_cycles = int(
        raw["processor_cycles"]
    )

    completed_commands = int(
        raw[
            "semantic_commands_completed"
        ]
    )

    energy_per_command = (
        cost_result[
            "total_normalized_energy"
        ]
        / completed_commands
        if completed_commands
        else 0.0
    )

    evaluation = {
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
        "raw_event_totals": (
            dict(raw)
        ),
        "architecture_specific_metrics": (
            dict(specific)
        ),
        "comparison_metrics": (
            dict(metrics)
        ),
        "normalized_cost": {
            "profile_name": (
                cost_result[
                    "profile_name"
                ]
            ),
            "cost_unit": (
                cost_result[
                    "cost_unit"
                ]
            ),
            "cost_profile_sha256": (
                cost_result[
                    "cost_profile_sha256"
                ]
            ),
            "event_totals": (
                cost_result[
                    "event_totals"
                ]
            ),
            "cost_contribution_totals": (
                cost_result[
                    "cost_contribution_totals"
                ]
            ),
            "peak_cycle_normalized_energy": (
                cost_result[
                    "peak_cycle_normalized_energy"
                ]
            ),
            "total_normalized_energy": (
                cost_result[
                    "total_normalized_energy"
                ]
            ),
            "normalized_energy_per_completed_command": (
                energy_per_command
            ),
            "cycle_normalized_energy_sha256": (
                sha256_hex(
                    canonical_json_bytes(
                        cost_result[
                            "cycle_normalized_energy"
                        ]
                    )
                )
            ),
        },
        "thermal_proxy": {
            "profile_name": (
                thermal_result[
                    "profile_name"
                ]
            ),
            "temperature_unit": (
                thermal_result[
                    "temperature_unit"
                ]
            ),
            "thermal_profile_sha256": (
                thermal_result[
                    "thermal_profile_sha256"
                ]
            ),
            "peak_temperature_proxy": (
                thermal_result[
                    "peak_temperature_proxy"
                ]
            ),
            "final_temperature_proxy": (
                thermal_result[
                    "final_temperature_proxy"
                ]
            ),
            "temperature_proxy_trace_sha256": (
                sha256_hex(
                    canonical_json_bytes(
                        thermal_result[
                            "temperature_proxy_trace"
                        ]
                    )
                )
            ),
        },
        "integrity": {
            "event_trace_closure": (
                cost_result[
                    "event_totals"
                ]
                == expected_event_totals
            ),
            "cost_cycle_count_closure": (
                cost_result[
                    "cycle_count"
                ]
                == processor_cycles
            ),
            "thermal_cycle_count_closure": (
                thermal_result[
                    "cycle_count"
                ]
                == processor_cycles
            ),
            "finite_numeric_values": (
                all_finite_numbers(
                    {
                        "raw": raw,
                        "metrics": metrics,
                        "specific": specific,
                        "peak_cycle_normalized_energy": (
                            cost_result[
                                "peak_cycle_normalized_energy"
                            ]
                        ),
                        "total_normalized_energy": (
                            cost_result[
                                "total_normalized_energy"
                            ]
                        ),
                        "normalized_energy_per_completed_command": (
                            energy_per_command
                        ),
                        "peak_temperature_proxy": (
                            thermal_result[
                                "peak_temperature_proxy"
                            ]
                        ),
                        "final_temperature_proxy": (
                            thermal_result[
                                "final_temperature_proxy"
                            ]
                        ),
                    }
                )
            ),
        },
    }

    comparison_row = {
        "architecture_id": (
            architecture_id
        ),
        "semantic_commands_issued": (
            raw[
                "semantic_commands_issued"
            ]
        ),
        "semantic_commands_completed": (
            raw[
                "semantic_commands_completed"
            ]
        ),
        "semantic_completion_ratio": (
            metrics[
                "semantic_completion_ratio"
            ]
        ),
        "semantic_output_match": (
            metrics[
                "semantic_output_match"
            ]
        ),
        "completion_ticks": (
            metrics[
                "completion_ticks"
            ]
        ),
        "mean_latency_ticks": (
            metrics[
                "mean_latency_ticks"
            ]
        ),
        "p95_latency_ticks": (
            metrics[
                "p95_latency_ticks"
            ]
        ),
        "maximum_latency_ticks": (
            metrics[
                "maximum_latency_ticks"
            ]
        ),
        "throughput_commands_per_tick": (
            metrics[
                "throughput_commands_per_tick"
            ]
        ),
        "logical_state_changes": (
            metrics[
                "logical_state_changes"
            ]
        ),
        "encoded_bit_toggles": (
            metrics[
                "encoded_bit_toggles"
            ]
        ),
        "processor_cycles": (
            metrics[
                "processor_cycles"
            ]
        ),
        "active_clocked_cycles": (
            metrics[
                "active_clocked_cycles"
            ]
        ),
        "active_clock_fraction": (
            metrics[
                "active_clock_fraction"
            ]
        ),
        "peak_cycle_normalized_energy": (
            cost_result[
                "peak_cycle_normalized_energy"
            ]
        ),
        "total_normalized_energy": (
            cost_result[
                "total_normalized_energy"
            ]
        ),
        "normalized_energy_per_completed_command": (
            energy_per_command
        ),
        "peak_temperature_proxy": (
            thermal_result[
                "peak_temperature_proxy"
            ]
        ),
        "final_temperature_proxy": (
            thermal_result[
                "final_temperature_proxy"
            ]
        ),
    }

    return (
        evaluation,
        comparison_row,
    )


def build_integrity_checks(
    *,
    workload_sha256: str,
    cost_profile_sha256: str,
    thermal_profile_sha256: str,
    evaluations: Sequence[
        Mapping[str, Any]
    ],
    comparison_matrix: Sequence[
        Mapping[str, Any]
    ],
) -> dict[str, bool]:
    architecture_ids = [
        str(
            row[
                "architecture_id"
            ]
        )
        for row in evaluations
    ]

    matrix_ids = [
        str(
            row[
                "architecture_id"
            ]
        )
        for row in comparison_matrix
    ]

    return {
        "architecture_order_match": (
            architecture_ids
            == list(
                ARCHITECTURE_ORDER
            )
            and matrix_ids
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "architecture_ids_unique": (
            len(
                set(
                    architecture_ids
                )
            )
            == len(
                ARCHITECTURE_ORDER
            )
        ),
        "same_workload_digest": all(
            row[
                "workload_sha256"
            ]
            == workload_sha256
            for row in evaluations
        ),
        "same_cost_profile_digest": all(
            row[
                "normalized_cost"
            ][
                "cost_profile_sha256"
            ]
            == cost_profile_sha256
            for row in evaluations
        ),
        "same_thermal_profile_digest": all(
            row[
                "thermal_proxy"
            ][
                "thermal_profile_sha256"
            ]
            == thermal_profile_sha256
            for row in evaluations
        ),
        "architecture_result_digests_valid": all(
            isinstance(
                row[
                    "architecture_result_sha256"
                ],
                str,
            )
            and len(
                row[
                    "architecture_result_sha256"
                ]
            )
            == 64
            for row in evaluations
        ),
        "event_trace_closure": all(
            row[
                "integrity"
            ][
                "event_trace_closure"
            ]
            for row in evaluations
        ),
        "cost_cycle_count_closure": all(
            row[
                "integrity"
            ][
                "cost_cycle_count_closure"
            ]
            for row in evaluations
        ),
        "thermal_cycle_count_closure": all(
            row[
                "integrity"
            ][
                "thermal_cycle_count_closure"
            ]
            for row in evaluations
        ),
        "finite_numeric_values": all(
            row[
                "integrity"
            ][
                "finite_numeric_values"
            ]
            for row in evaluations
        ),
    }


def build_qualification_checks(
    *,
    workload_package: Mapping[
        str,
        Any,
    ],
    evaluations: Sequence[
        Mapping[str, Any]
    ],
    integrity_checks: Mapping[
        str,
        bool,
    ],
) -> dict[str, bool]:
    command_count = int(
        workload_package[
            "workload_profile"
        ][
            "command_count"
        ]
    )

    by_id = {
        str(
            row[
                "architecture_id"
            ]
        ): row
        for row in evaluations
    }

    frp_specific = by_id[
        "frp_v1_7_0_quantized_shadow"
    ][
        "architecture_specific_metrics"
    ]

    return {
        "same_workload_digest": (
            integrity_checks[
                "same_workload_digest"
            ]
        ),
        "same_cost_profile_digest": (
            integrity_checks[
                "same_cost_profile_digest"
            ]
        ),
        "same_thermal_profile_digest": (
            integrity_checks[
                "same_thermal_profile_digest"
            ]
        ),
        "architecture_order_match": (
            integrity_checks[
                "architecture_order_match"
            ]
        ),
        "all_architectures_completed_workload": all(
            row[
                "raw_event_totals"
            ][
                "semantic_commands_issued"
            ]
            == command_count
            and row[
                "raw_event_totals"
            ][
                "semantic_commands_completed"
            ]
            == command_count
            for row in evaluations
        ),
        "semantic_output_match_one": all(
            row[
                "comparison_metrics"
            ][
                "semantic_output_match"
            ]
            == 1.0
            for row in evaluations
        ),
        "finite_metric_values": (
            integrity_checks[
                "finite_numeric_values"
            ]
        ),
        "cost_trace_closure": (
            integrity_checks[
                "event_trace_closure"
            ]
            and integrity_checks[
                "cost_cycle_count_closure"
            ]
        ),
        "thermal_trace_cycle_closure": (
            integrity_checks[
                "thermal_cycle_count_closure"
            ]
        ),
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
    }


def build_architecture_comparison_package(
    *,
    workload_package: Mapping[
        str,
        Any,
    ],
    cost_profile: NormalizedCostProfile,
    thermal_profile: ThermalProxyProfile,
    frp_scheduler: str = (
        DEFAULT_FRP_SCHEDULER
    ),
) -> dict[str, Any]:
    validate_workload_package(
        workload_package
    )

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

    architecture_ids = [
        str(
            result[
                "architecture_id"
            ]
        )
        for result in architecture_results
    ]

    if architecture_ids != list(
        ARCHITECTURE_ORDER
    ):
        raise ArchitectureComparisonError(
            "architecture execution order mismatch"
        )

    evaluations: list[
        dict[str, Any]
    ] = []

    comparison_matrix: list[
        dict[str, Any]
    ] = []

    for result in architecture_results:
        validate_architecture_result(
            result,
            workload_sha256=(
                workload_sha256
            ),
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
            evaluation
        )

        comparison_matrix.append(
            comparison_row
        )

    integrity_checks = (
        build_integrity_checks(
            workload_sha256=(
                workload_sha256
            ),
            cost_profile_sha256=(
                cost_profile.
                cost_profile_sha256
            ),
            thermal_profile_sha256=(
                thermal_profile.
                thermal_profile_sha256
            ),
            evaluations=(
                evaluations
            ),
            comparison_matrix=(
                comparison_matrix
            ),
        )
    )

    qualification_checks = (
        build_qualification_checks(
            workload_package=(
                workload_package
            ),
            evaluations=(
                evaluations
            ),
            integrity_checks=(
                integrity_checks
            ),
        )
    )

    digest_payload = {
        "schema": (
            COMPARISON_SCHEMA
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
        "architecture_order": (
            list(
                ARCHITECTURE_ORDER
            )
        ),
        "workload_profile": (
            dict(
                workload_package[
                    "workload_profile"
                ]
            )
        ),
        "workload_sha256": (
            workload_sha256
        ),
        "cost_profile": (
            cost_profile_metadata(
                cost_profile
            )
        ),
        "cost_profile_sha256": (
            cost_profile.
            cost_profile_sha256
        ),
        "thermal_profile": (
            thermal_profile_metadata(
                thermal_profile
            )
        ),
        "thermal_profile_sha256": (
            thermal_profile.
            thermal_profile_sha256
        ),
        "architectures": (
            evaluations
        ),
        "comparison_matrix": (
            comparison_matrix
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
        "comparison_package_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            digest_payload
        )
    )

    return package


def raises_benchmark_error(
    callback: Any,
) -> bool:
    try:
        callback()

    except (
        ArchitectureComparisonError,
        BinarySynchronousError,
        BinaryClockGatedError,
        DirectTernaryError,
        FRPAdapterError,
        CostModelError,
        ThermalModelError,
        WorkloadError,
        ValueError,
        IndexError,
        KeyError,
    ):
        return True

    return False


def run_self_test() -> dict[str, Any]:
    workload = build_workload_package(
        WorkloadProfile()
    )

    cost_profile = (
        build_default_cost_profile()
    )

    thermal_profile = (
        build_default_thermal_profile()
    )

    package_a = (
        build_architecture_comparison_package(
            workload_package=(
                workload
            ),
            cost_profile=(
                cost_profile
            ),
            thermal_profile=(
                thermal_profile
            ),
            frp_scheduler=(
                DEFAULT_FRP_SCHEDULER
            ),
        )
    )

    package_b = (
        build_architecture_comparison_package(
            workload_package=(
                workload
            ),
            cost_profile=(
                cost_profile
            ),
            thermal_profile=(
                thermal_profile
            ),
            frp_scheduler=(
                DEFAULT_FRP_SCHEDULER
            ),
        )
    )

    invalid_workload = dict(
        workload
    )

    invalid_workload[
        "schema"
    ] = "invalid"

    checks = {
        "comparison_schema_correct": (
            package_a[
                "schema"
            ]
            == COMPARISON_SCHEMA
        ),
        "architecture_order_exact": (
            package_a[
                "architecture_order"
            ]
            == list(
                ARCHITECTURE_ORDER
            )
        ),
        "four_architectures_present": (
            len(
                package_a[
                    "architectures"
                ]
            )
            == 4
        ),
        "comparison_matrix_four_rows": (
            len(
                package_a[
                    "comparison_matrix"
                ]
            )
            == 4
        ),
        "workload_digest_preserved": (
            package_a[
                "workload_sha256"
            ]
            == workload[
                "workload_sha256"
            ]
        ),
        "cost_profile_digest_preserved": (
            package_a[
                "cost_profile_sha256"
            ]
            == cost_profile.
            cost_profile_sha256
        ),
        "thermal_profile_digest_preserved": (
            package_a[
                "thermal_profile_sha256"
            ]
            == thermal_profile.
            thermal_profile_sha256
        ),
        "integrity_status_pass": (
            package_a[
                "integrity"
            ][
                "status"
            ]
            == "PASS"
        ),
        "all_integrity_checks_pass": all(
            package_a[
                "integrity"
            ][
                "checks"
            ].values()
        ),
        "qualification_status_pass": (
            package_a[
                "qualification"
            ][
                "status"
            ]
            == "PASS"
        ),
        "all_qualification_checks_pass": all(
            package_a[
                "qualification"
            ][
                "checks"
            ].values()
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
        "semantic_output_match_one_all": all(
            row[
                "semantic_output_match"
            ]
            == 1.0
            for row in package_a[
                "comparison_matrix"
            ]
        ),
        "comparison_rows_finite": (
            all_finite_numbers(
                package_a[
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
        "deterministic_package_digest_repeat": (
            package_a[
                "comparison_package_sha256"
            ]
            == package_b[
                "comparison_package_sha256"
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
        "comparison_package_digest_length_64": (
            len(
                package_a[
                    "comparison_package_sha256"
                ]
            )
            == 64
        ),
        "invalid_workload_rejected": (
            raises_benchmark_error(
                lambda: (
                    build_architecture_comparison_package(
                        workload_package=(
                            invalid_workload
                        ),
                        cost_profile=(
                            cost_profile
                        ),
                        thermal_profile=(
                            thermal_profile
                        ),
                        frp_scheduler=(
                            DEFAULT_FRP_SCHEDULER
                        ),
                    )
                )
            )
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
        "status": (
            status
        ),
        "check_count": (
            len(checks)
        ),
        "checks": (
            checks
        ),
        "workload_sha256": (
            package_a[
                "workload_sha256"
            ]
        ),
        "cost_profile_sha256": (
            package_a[
                "cost_profile_sha256"
            ]
        ),
        "thermal_profile_sha256": (
            package_a[
                "thermal_profile_sha256"
            ]
        ),
        "comparison_package_sha256": (
            package_a[
                "comparison_package_sha256"
            ]
        ),
        "qualification_status": (
            package_a[
                "qualification"
            ][
                "status"
            ]
        ),
        "comparison_matrix": (
            package_a[
                "comparison_matrix"
            ]
        ),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Execute the FRP Comparative "
            "Architecture Benchmark Suite and "
            "emit one machine-readable "
            "comparison matrix."
        )
    )

    parser.add_argument(
        "--workload-profile",
        type=Path,
        help=(
            "Optional workload profile JSON path. "
            "The built-in default profile is used "
            "when omitted."
        ),
    )

    parser.add_argument(
        "--workload-package",
        type=Path,
        help=(
            "Optional pre-generated validated "
            "workload package JSON path."
        ),
    )

    parser.add_argument(
        "--cost-profile",
        type=Path,
        help=(
            "Optional normalized cost-profile "
            "JSON path. The built-in "
            "unit_event_cost_v1 profile is used "
            "when omitted."
        ),
    )

    parser.add_argument(
        "--thermal-profile",
        type=Path,
        help=(
            "Optional thermal proxy profile JSON "
            "path. The built-in "
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
        default=(
            DEFAULT_FRP_SCHEDULER
        ),
        help=(
            "FRP M15 scheduler mode."
        ),
    )

    parser.add_argument(
        "--write",
        type=Path,
        help=(
            "Optional path for the complete "
            "comparison package JSON."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run deterministic end-to-end "
            "comparison self-tests."
        ),
    )

    parser.add_argument(
        "--output",
        choices=(
            "json",
            "text",
        ),
        default="json",
        help=(
            "Output format."
        ),
    )

    return parser


def print_text_result(
    result: Mapping[str, Any],
    *,
    self_test: bool,
) -> None:
    if self_test:
        print(
            "FRP COMPARATIVE ARCHITECTURE "
            "BENCHMARK SELF TEST"
        )

        print(
            f"status="
            f"{result['status']}"
        )

        print(
            f"checks="
            f"{result['check_count']}"
        )

        print(
            "workload_sha256="
            f"{result['workload_sha256']}"
        )

        print(
            "comparison_package_sha256="
            f"{result['comparison_package_sha256']}"
        )

        print(
            "qualification_status="
            f"{result['qualification_status']}"
        )

        return

    print(
        "FRP COMPARATIVE ARCHITECTURE "
        "BENCHMARK SUITE"
    )

    print(
        f"schema="
        f"{result['schema']}"
    )

    print(
        "workload_sha256="
        f"{result['workload_sha256']}"
    )

    print(
        "cost_profile_sha256="
        f"{result['cost_profile_sha256']}"
    )

    print(
        "thermal_profile_sha256="
        f"{result['thermal_profile_sha256']}"
    )

    print(
        "qualification_status="
        f"{result['qualification']['status']}"
    )

    print(
        "comparison_package_sha256="
        f"{result['comparison_package_sha256']}"
    )

    for row in result[
        "comparison_matrix"
    ]:
        print()

        print(
            f"architecture_id="
            f"{row['architecture_id']}"
        )

        print(
            f"completion_ticks="
            f"{row['completion_ticks']}"
        )

        print(
            "semantic_output_match="
            f"{row['semantic_output_match']}"
        )

        print(
            "total_normalized_energy="
            f"{row['total_normalized_energy']}"
        )

        print(
            "peak_temperature_proxy="
            f"{row['peak_temperature_proxy']}"
        )

        print(
            "final_temperature_proxy="
            f"{row['final_temperature_proxy']}"
        )


def main() -> int:
    args = (
        build_parser().parse_args()
    )

    try:
        if args.self_test:
            result = run_self_test()

        else:
            workload_package = (
                load_or_build_workload(
                    workload_profile_path=(
                        args.workload_profile
                    ),
                    workload_package_path=(
                        args.workload_package
                    ),
                )
            )

            cost_profile = (
                load_cost_profile(
                    args.cost_profile
                )
                if args.cost_profile
                else build_default_cost_profile()
            )

            thermal_profile = (
                load_thermal_profile(
                    args.thermal_profile
                )
                if args.thermal_profile
                else build_default_thermal_profile()
            )

            result = (
                build_architecture_comparison_package(
                    workload_package=(
                        workload_package
                    ),
                    cost_profile=(
                        cost_profile
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
        ArchitectureComparisonError,
        BinarySynchronousError,
        BinaryClockGatedError,
        DirectTernaryError,
        FRPAdapterError,
        CostModelError,
        ThermalModelError,
        WorkloadError,
        ValueError,
        IndexError,
        KeyError,
    ) as exc:
        raise SystemExit(
            "architecture comparison error: "
            f"{exc}"
        ) from exc


if __name__ == "__main__":
    raise SystemExit(main())

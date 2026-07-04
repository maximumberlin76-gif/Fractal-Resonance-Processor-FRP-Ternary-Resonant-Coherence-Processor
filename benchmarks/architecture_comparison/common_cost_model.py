#!/usr/bin/env python3
"""Shared normalized event-cost model for FRP architecture comparisons."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

COST_PROFILE_SCHEMA = "frp.benchmark.normalized_cost_profile.v1"
COST_RESULT_SCHEMA = "frp.benchmark.normalized_cost_result.v1"
COST_SELF_TEST_SCHEMA = "frp.benchmark.normalized_cost_model.self_test.v1"
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
DEFAULT_PROFILE_NAME = "unit_event_cost_v1"
DEFAULT_COST_UNIT = "normalized_activity_unit"

EVENT_TO_COST_CLASS = {
    "encoded_bit_toggles": "encoded_bit_toggle",
    "clocked_state_bits": "clocked_state_bit",
    "register_write_bits": "register_write_bit",
    "comparison_events": "comparison_event",
    "control_events": "control_event",
    "queue_reads": "queue_read",
    "queue_writes": "queue_write",
    "lut_reads_32": "lut_read_32",
    "fixed_point_multiplies_32x32": "fixed_point_multiply_32x32",
    "fixed_point_accumulates_64": "fixed_point_accumulate_64",
    "fixed_point_adds_32": "fixed_point_add_32",
    "fixed_point_compares_32": "fixed_point_compare_32",
}

EVENT_FIELDS = tuple(EVENT_TO_COST_CLASS)
COST_CLASSES = tuple(EVENT_TO_COST_CLASS.values())

DEFAULT_COSTS = {
    cost_class: 1.0
    for cost_class in COST_CLASSES
}


class CostModelError(ValueError):
    """Raised when a cost profile or raw event stream is invalid."""


@dataclass(frozen=True)
class NormalizedCostProfile:
    """Validated architecture-neutral normalized event-cost profile."""

    profile_name: str
    cost_unit: str
    costs: Mapping[str, float]
    cost_profile_sha256: str

    def cost_for_event(self, event_field: str) -> float:
        if event_field not in EVENT_TO_COST_CLASS:
            raise CostModelError(
                f"unknown raw event field: {event_field}"
            )
        return self.costs[
            EVENT_TO_COST_CLASS[event_field]
        ]


def canonical_json_bytes(value: Any) -> bytes:
    """Serialize JSON deterministically for hashing and byte comparison."""

    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        allow_nan=False,
    ).encode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _validate_nonnegative_finite_number(
    value: Any,
    field_name: str,
) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise CostModelError(
            f"{field_name} must be a numeric value"
        )

    numeric = float(value)

    if not math.isfinite(numeric):
        raise CostModelError(
            f"{field_name} must be finite"
        )

    if numeric < 0.0:
        raise CostModelError(
            f"{field_name} must be nonnegative"
        )

    return numeric


def _profile_digest_payload(
    profile_name: str,
    cost_unit: str,
    costs: Mapping[str, float],
) -> dict[str, Any]:
    return {
        "schema": COST_PROFILE_SCHEMA,
        "suite_name": SUITE_NAME,
        "profile_name": profile_name,
        "cost_unit": cost_unit,
        "costs": {
            cost_class: float(costs[cost_class])
            for cost_class in COST_CLASSES
        },
    }


def build_cost_profile_package(
    *,
    profile_name: str = DEFAULT_PROFILE_NAME,
    cost_unit: str = DEFAULT_COST_UNIT,
    costs: Mapping[str, Any] | None = None,
) -> dict[str, Any]:
    """Build and validate a complete normalized cost-profile package."""

    if not isinstance(profile_name, str) or not profile_name.strip():
        raise CostModelError(
            "profile_name must be a nonempty string"
        )

    if not isinstance(cost_unit, str) or not cost_unit.strip():
        raise CostModelError(
            "cost_unit must be a nonempty string"
        )

    raw_costs = DEFAULT_COSTS if costs is None else costs

    if not isinstance(raw_costs, Mapping):
        raise CostModelError(
            "costs must be an object"
        )

    unknown = sorted(set(raw_costs) - set(COST_CLASSES))
    missing = sorted(set(COST_CLASSES) - set(raw_costs))

    if unknown:
        raise CostModelError(
            "unknown cost class(es): " + ", ".join(unknown)
        )

    if missing:
        raise CostModelError(
            "missing cost class(es): " + ", ".join(missing)
        )

    validated_costs = {
        cost_class: _validate_nonnegative_finite_number(
            raw_costs[cost_class],
            f"costs.{cost_class}",
        )
        for cost_class in COST_CLASSES
    }

    if not any(value > 0.0 for value in validated_costs.values()):
        raise CostModelError(
            "at least one normalized cost must be greater than zero"
        )

    digest_payload = _profile_digest_payload(
        profile_name.strip(),
        cost_unit.strip(),
        validated_costs,
    )

    package = dict(digest_payload)
    package["cost_profile_sha256"] = sha256_hex(
        canonical_json_bytes(digest_payload)
    )

    validate_cost_profile_package(package)
    return package


def validate_cost_profile_package(
    package: Mapping[str, Any],
) -> None:
    """Validate a cost-profile package and recompute its digest."""

    if package.get("schema") != COST_PROFILE_SCHEMA:
        raise CostModelError(
            "invalid cost-profile schema"
        )

    if package.get("suite_name") != SUITE_NAME:
        raise CostModelError(
            "invalid suite_name"
        )

    profile_name = package.get("profile_name")
    cost_unit = package.get("cost_unit")
    raw_costs = package.get("costs")

    if not isinstance(profile_name, str) or not profile_name.strip():
        raise CostModelError(
            "profile_name must be a nonempty string"
        )

    if not isinstance(cost_unit, str) or not cost_unit.strip():
        raise CostModelError(
            "cost_unit must be a nonempty string"
        )

    if not isinstance(raw_costs, Mapping):
        raise CostModelError(
            "costs must be an object"
        )

    unknown = sorted(set(raw_costs) - set(COST_CLASSES))
    missing = sorted(set(COST_CLASSES) - set(raw_costs))

    if unknown:
        raise CostModelError(
            "unknown cost class(es): " + ", ".join(unknown)
        )

    if missing:
        raise CostModelError(
            "missing cost class(es): " + ", ".join(missing)
        )

    validated_costs = {
        cost_class: _validate_nonnegative_finite_number(
            raw_costs[cost_class],
            f"costs.{cost_class}",
        )
        for cost_class in COST_CLASSES
    }

    if not any(value > 0.0 for value in validated_costs.values()):
        raise CostModelError(
            "at least one normalized cost must be greater than zero"
        )

    expected_digest = sha256_hex(
        canonical_json_bytes(
            _profile_digest_payload(
                profile_name,
                cost_unit,
                validated_costs,
            )
        )
    )

    if package.get("cost_profile_sha256") != expected_digest:
        raise CostModelError(
            "cost_profile_sha256 mismatch"
        )


def profile_from_package(
    package: Mapping[str, Any],
) -> NormalizedCostProfile:
    validate_cost_profile_package(package)

    costs = {
        cost_class: float(package["costs"][cost_class])
        for cost_class in COST_CLASSES
    }

    return NormalizedCostProfile(
        profile_name=str(package["profile_name"]),
        cost_unit=str(package["cost_unit"]),
        costs=costs,
        cost_profile_sha256=str(
            package["cost_profile_sha256"]
        ),
    )


def load_cost_profile(
    path: Path,
) -> NormalizedCostProfile:
    try:
        value = json.loads(
            path.read_text(encoding="utf-8")
        )
    except OSError as exc:
        raise CostModelError(
            f"unable to read cost profile: {path}"
        ) from exc
    except json.JSONDecodeError as exc:
        raise CostModelError(
            f"invalid cost profile JSON: {path}"
        ) from exc

    if not isinstance(value, Mapping):
        raise CostModelError(
            "cost-profile JSON must contain an object"
        )

    return profile_from_package(value)


def empty_event_counts() -> dict[str, int]:
    """Return a complete zero-valued cost-event counter object."""

    return {
        event_field: 0
        for event_field in EVENT_FIELDS
    }


def validate_event_counts(
    event_counts: Mapping[str, Any],
) -> dict[str, int]:
    """Validate one complete raw cost-event counter object."""

    if not isinstance(event_counts, Mapping):
        raise CostModelError(
            "event_counts must be an object"
        )

    unknown = sorted(set(event_counts) - set(EVENT_FIELDS))
    missing = sorted(set(EVENT_FIELDS) - set(event_counts))

    if unknown:
        raise CostModelError(
            "unknown event field(s): " + ", ".join(unknown)
        )

    if missing:
        raise CostModelError(
            "missing event field(s): " + ", ".join(missing)
        )

    validated: dict[str, int] = {}

    for event_field in EVENT_FIELDS:
        value = event_counts[event_field]

        if isinstance(value, bool) or not isinstance(value, int):
            raise CostModelError(
                f"{event_field} must be an integer"
            )

        if value < 0:
            raise CostModelError(
                f"{event_field} must be nonnegative"
            )

        validated[event_field] = value

    return validated


def calculate_cycle_cost(
    event_counts: Mapping[str, Any],
    profile: NormalizedCostProfile,
) -> dict[str, Any]:
    """Calculate normalized cost for one architecture cycle."""

    events = validate_event_counts(event_counts)

    contributions = {
        EVENT_TO_COST_CLASS[event_field]: (
            events[event_field]
            * profile.cost_for_event(event_field)
        )
        for event_field in EVENT_FIELDS
    }

    total = math.fsum(contributions.values())

    if not math.isfinite(total):
        raise CostModelError(
            "cycle normalized cost is not finite"
        )

    return {
        "event_counts": events,
        "cost_contributions": contributions,
        "normalized_cycle_cost": total,
    }


def calculate_trace_cost(
    cycle_event_counts: Sequence[Mapping[str, Any]],
    profile: NormalizedCostProfile,
) -> dict[str, Any]:
    """Aggregate one complete per-cycle architecture event trace."""

    if not isinstance(cycle_event_counts, Sequence):
        raise CostModelError(
            "cycle_event_counts must be a sequence"
        )

    event_totals = empty_event_counts()
    contribution_totals = {
        cost_class: 0.0
        for cost_class in COST_CLASSES
    }

    cycle_costs: list[float] = []

    for event_counts in cycle_event_counts:
        cycle = calculate_cycle_cost(
            event_counts,
            profile,
        )

        cycle_cost = float(
            cycle["normalized_cycle_cost"]
        )

        cycle_costs.append(cycle_cost)

        for event_field in EVENT_FIELDS:
            event_totals[event_field] += cycle[
                "event_counts"
            ][event_field]

        for cost_class in COST_CLASSES:
            contribution_totals[cost_class] += cycle[
                "cost_contributions"
            ][cost_class]

    total_normalized_energy = math.fsum(cycle_costs)
    peak_cycle_normalized_energy = (
        max(cycle_costs)
        if cycle_costs
        else 0.0
    )

    contribution_sum = math.fsum(
        contribution_totals.values()
    )

    if not math.isclose(
        total_normalized_energy,
        contribution_sum,
        rel_tol=0.0,
        abs_tol=1e-12,
    ):
        raise CostModelError(
            "cost contribution total does not match trace total"
        )

    return {
        "schema": COST_RESULT_SCHEMA,
        "suite_name": SUITE_NAME,
        "profile_name": profile.profile_name,
        "cost_unit": profile.cost_unit,
        "cost_profile_sha256": profile.cost_profile_sha256,
        "cycle_count": len(cycle_costs),
        "cycle_normalized_energy": cycle_costs,
        "event_totals": event_totals,
        "cost_contribution_totals": contribution_totals,
        "peak_cycle_normalized_energy": (
            peak_cycle_normalized_energy
        ),
        "total_normalized_energy": total_normalized_energy,
    }


def build_demonstration_trace() -> list[dict[str, int]]:
    """Build a small deterministic trace for CLI demonstration and tests."""

    cycle_0 = empty_event_counts()
    cycle_0["clocked_state_bits"] = 16
    cycle_0["comparison_events"] = 1
    cycle_0["control_events"] = 1

    cycle_1 = empty_event_counts()
    cycle_1["encoded_bit_toggles"] = 2
    cycle_1["clocked_state_bits"] = 16
    cycle_1["register_write_bits"] = 2
    cycle_1["comparison_events"] = 1
    cycle_1["control_events"] = 1

    cycle_2 = empty_event_counts()
    cycle_2["clocked_state_bits"] = 16
    cycle_2["queue_reads"] = 1
    cycle_2["queue_writes"] = 1
    cycle_2["lut_reads_32"] = 4
    cycle_2["fixed_point_multiplies_32x32"] = 4
    cycle_2["fixed_point_accumulates_64"] = 4
    cycle_2["fixed_point_adds_32"] = 2
    cycle_2["fixed_point_compares_32"] = 1

    return [
        cycle_0,
        cycle_1,
        cycle_2,
    ]


def write_json(
    path: Path,
    value: Any,
) -> None:
    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    text = json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        indent=2,
        allow_nan=False,
    )

    path.write_text(
        text + "\n",
        encoding="utf-8",
    )


def _raises_cost_error(callback: Any) -> bool:
    try:
        callback()
    except CostModelError:
        return True
    return False


def run_self_test() -> dict[str, Any]:
    package_a = build_cost_profile_package()
    package_b = build_cost_profile_package()

    profile = profile_from_package(package_a)

    empty_events = empty_event_counts()
    empty_cycle = calculate_cycle_cost(
        empty_events,
        profile,
    )

    single_toggle_events = empty_event_counts()
    single_toggle_events["encoded_bit_toggles"] = 1

    single_toggle_cycle = calculate_cycle_cost(
        single_toggle_events,
        profile,
    )

    demonstration_trace = build_demonstration_trace()
    trace_result = calculate_trace_cost(
        demonstration_trace,
        profile,
    )

    expected_event_totals = empty_event_counts()
    for row in demonstration_trace:
        for event_field in EVENT_FIELDS:
            expected_event_totals[event_field] += row[event_field]

    expected_total = float(
        sum(expected_event_totals.values())
    )

    tampered_package = json.loads(
        json.dumps(package_a)
    )
    tampered_package["costs"]["queue_read"] = 2.0

    negative_events = empty_event_counts()
    negative_events["queue_reads"] = -1

    unknown_events = dict(empty_event_counts())
    unknown_events["unknown_event"] = 1

    missing_events = dict(empty_event_counts())
    missing_events.pop("control_events")

    checks = {
        "default_profile_valid": True,
        "exact_cost_class_set": (
            set(package_a["costs"])
            == set(COST_CLASSES)
        ),
        "all_default_costs_equal_one": all(
            value == 1.0
            for value in package_a["costs"].values()
        ),
        "deterministic_profile_digest_repeat": (
            package_a["cost_profile_sha256"]
            == package_b["cost_profile_sha256"]
        ),
        "deterministic_profile_byte_repeat": (
            canonical_json_bytes(package_a)
            == canonical_json_bytes(package_b)
        ),
        "profile_digest_length_64": (
            len(package_a["cost_profile_sha256"]) == 64
        ),
        "empty_event_object_complete": (
            set(empty_events) == set(EVENT_FIELDS)
            and all(value == 0 for value in empty_events.values())
        ),
        "empty_cycle_cost_zero": (
            empty_cycle["normalized_cycle_cost"] == 0.0
        ),
        "single_toggle_cost_one": (
            single_toggle_cycle["normalized_cycle_cost"] == 1.0
        ),
        "trace_cycle_count": (
            trace_result["cycle_count"]
            == len(demonstration_trace)
        ),
        "trace_event_totals": (
            trace_result["event_totals"]
            == expected_event_totals
        ),
        "trace_total_matches_unit_event_count": (
            trace_result["total_normalized_energy"]
            == expected_total
        ),
        "trace_peak_matches_cycle_maximum": (
            trace_result["peak_cycle_normalized_energy"]
            == max(
                trace_result["cycle_normalized_energy"]
            )
        ),
        "trace_contribution_sum_matches_total": math.isclose(
            math.fsum(
                trace_result[
                    "cost_contribution_totals"
                ].values()
            ),
            trace_result["total_normalized_energy"],
            rel_tol=0.0,
            abs_tol=1e-12,
        ),
        "tampered_profile_digest_rejected": _raises_cost_error(
            lambda: validate_cost_profile_package(
                tampered_package
            )
        ),
        "negative_event_rejected": _raises_cost_error(
            lambda: validate_event_counts(
                negative_events
            )
        ),
        "unknown_event_rejected": _raises_cost_error(
            lambda: validate_event_counts(
                unknown_events
            )
        ),
        "missing_event_rejected": _raises_cost_error(
            lambda: validate_event_counts(
                missing_events
            )
        ),
        "unknown_cost_class_rejected": _raises_cost_error(
            lambda: build_cost_profile_package(
                costs={
                    **DEFAULT_COSTS,
                    "unknown_cost": 1.0,
                }
            )
        ),
        "negative_cost_rejected": _raises_cost_error(
            lambda: build_cost_profile_package(
                costs={
                    **DEFAULT_COSTS,
                    "queue_read": -1.0,
                }
            )
        ),
        "profile_json_roundtrip": (
            json.loads(
                canonical_json_bytes(package_a).decode("utf-8")
            )
            == package_a
        ),
    }

    status = (
        "PASS"
        if all(checks.values())
        else "FAIL"
    )

    return {
        "schema": COST_SELF_TEST_SCHEMA,
        "status": status,
        "check_count": len(checks),
        "checks": checks,
        "default_cost_profile_sha256": (
            package_a["cost_profile_sha256"]
        ),
        "default_profile": package_a,
        "demonstration_trace_result": trace_result,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Apply one shared normalized event-cost model "
            "to comparative architecture event traces."
        )
    )

    parser.add_argument(
        "--profile",
        type=Path,
        help=(
            "Optional normalized cost-profile JSON path. "
            "The default is unit_event_cost_v1."
        ),
    )

    parser.add_argument(
        "--write-default-profile",
        type=Path,
        help=(
            "Write the canonical default normalized "
            "cost-profile JSON package."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Run normalized cost-model self-tests.",
    )

    parser.add_argument(
        "--output",
        choices=("json", "text"),
        default="json",
        help="Output format.",
    )

    return parser


def main() -> int:
    args = build_parser().parse_args()

    try:
        if args.write_default_profile:
            package = build_cost_profile_package()
            write_json(
                args.write_default_profile,
                package,
            )

        if args.self_test:
            result = run_self_test()
        else:
            profile = (
                load_cost_profile(args.profile)
                if args.profile
                else profile_from_package(
                    build_cost_profile_package()
                )
            )

            result = calculate_trace_cost(
                build_demonstration_trace(),
                profile,
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
            if args.self_test:
                print(
                    "FRP COMPARATIVE NORMALIZED COST MODEL SELF TEST"
                )
                print(f"status={result['status']}")
                print(f"checks={result['check_count']}")
                print(
                    "default_cost_profile_sha256="
                    f"{result['default_cost_profile_sha256']}"
                )
            else:
                print(
                    "FRP COMPARATIVE NORMALIZED COST MODEL"
                )
                print(
                    f"profile_name={result['profile_name']}"
                )
                print(
                    "cost_profile_sha256="
                    f"{result['cost_profile_sha256']}"
                )
                print(
                    f"cycle_count={result['cycle_count']}"
                )
                print(
                    "total_normalized_energy="
                    f"{result['total_normalized_energy']}"
                )

        return (
            0
            if not args.self_test
            or result["status"] == "PASS"
            else 1
        )

    except CostModelError as exc:
        raise SystemExit(
            f"cost model error: {exc}"
        ) from exc


if __name__ == "__main__":
    raise SystemExit(main())

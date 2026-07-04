#!/usr/bin/env python3
"""Shared thermal proxy model for FRP architecture comparisons."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

THERMAL_PROFILE_SCHEMA = "frp.benchmark.thermal_proxy_profile.v1"
THERMAL_RESULT_SCHEMA = "frp.benchmark.thermal_proxy_result.v1"
THERMAL_SELF_TEST_SCHEMA = "frp.benchmark.thermal_proxy_model.self_test.v1"
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
DEFAULT_PROFILE_NAME = "common_rc_thermal_proxy_v1"
DEFAULT_TEMPERATURE_UNIT = "normalized_temperature_proxy"

DEFAULT_AMBIENT_TEMPERATURE_PROXY = 0.0
DEFAULT_THERMAL_DECAY = 0.95
DEFAULT_THERMAL_GAIN = 0.01


class ThermalModelError(ValueError):
    """Raised when a thermal profile or normalized cost trace is invalid."""


@dataclass(frozen=True)
class ThermalProxyProfile:
    """Validated architecture-neutral thermal proxy profile."""

    profile_name: str
    temperature_unit: str
    ambient_temperature_proxy: float
    thermal_decay: float
    thermal_gain: float
    thermal_profile_sha256: str


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


def _finite_number(
    value: Any,
    field_name: str,
) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ThermalModelError(
            f"{field_name} must be a numeric value"
        )

    numeric = float(value)

    if not math.isfinite(numeric):
        raise ThermalModelError(
            f"{field_name} must be finite"
        )

    return numeric


def _validate_profile_values(
    *,
    ambient_temperature_proxy: Any,
    thermal_decay: Any,
    thermal_gain: Any,
) -> tuple[float, float, float]:
    ambient = _finite_number(
        ambient_temperature_proxy,
        "ambient_temperature_proxy",
    )
    decay = _finite_number(
        thermal_decay,
        "thermal_decay",
    )
    gain = _finite_number(
        thermal_gain,
        "thermal_gain",
    )

    if ambient < 0.0:
        raise ThermalModelError(
            "ambient_temperature_proxy must be nonnegative"
        )

    if not 0.0 <= decay < 1.0:
        raise ThermalModelError(
            "thermal_decay must satisfy 0 <= thermal_decay < 1"
        )

    if gain < 0.0:
        raise ThermalModelError(
            "thermal_gain must be nonnegative"
        )

    return ambient, decay, gain


def _profile_digest_payload(
    *,
    profile_name: str,
    temperature_unit: str,
    ambient_temperature_proxy: float,
    thermal_decay: float,
    thermal_gain: float,
) -> dict[str, Any]:
    return {
        "schema": THERMAL_PROFILE_SCHEMA,
        "suite_name": SUITE_NAME,
        "profile_name": profile_name,
        "temperature_unit": temperature_unit,
        "ambient_temperature_proxy": ambient_temperature_proxy,
        "thermal_decay": thermal_decay,
        "thermal_gain": thermal_gain,
        "update_equation": (
            "ambient + (temperature - ambient) * thermal_decay "
            "+ normalized_cycle_cost * thermal_gain"
        ),
    }


def build_thermal_profile_package(
    *,
    profile_name: str = DEFAULT_PROFILE_NAME,
    temperature_unit: str = DEFAULT_TEMPERATURE_UNIT,
    ambient_temperature_proxy: Any = DEFAULT_AMBIENT_TEMPERATURE_PROXY,
    thermal_decay: Any = DEFAULT_THERMAL_DECAY,
    thermal_gain: Any = DEFAULT_THERMAL_GAIN,
) -> dict[str, Any]:
    """Build and validate the common thermal proxy profile."""

    if not isinstance(profile_name, str) or not profile_name.strip():
        raise ThermalModelError(
            "profile_name must be a nonempty string"
        )

    if not isinstance(temperature_unit, str) or not temperature_unit.strip():
        raise ThermalModelError(
            "temperature_unit must be a nonempty string"
        )

    ambient, decay, gain = _validate_profile_values(
        ambient_temperature_proxy=ambient_temperature_proxy,
        thermal_decay=thermal_decay,
        thermal_gain=thermal_gain,
    )

    digest_payload = _profile_digest_payload(
        profile_name=profile_name.strip(),
        temperature_unit=temperature_unit.strip(),
        ambient_temperature_proxy=ambient,
        thermal_decay=decay,
        thermal_gain=gain,
    )

    package = dict(digest_payload)
    package["thermal_profile_sha256"] = sha256_hex(
        canonical_json_bytes(digest_payload)
    )

    validate_thermal_profile_package(package)
    return package


def validate_thermal_profile_package(
    package: Mapping[str, Any],
) -> None:
    """Validate the common thermal proxy profile and recompute its digest."""

    if package.get("schema") != THERMAL_PROFILE_SCHEMA:
        raise ThermalModelError(
            "invalid thermal-profile schema"
        )

    if package.get("suite_name") != SUITE_NAME:
        raise ThermalModelError(
            "invalid suite_name"
        )

    profile_name = package.get("profile_name")
    temperature_unit = package.get("temperature_unit")

    if not isinstance(profile_name, str) or not profile_name.strip():
        raise ThermalModelError(
            "profile_name must be a nonempty string"
        )

    if not isinstance(temperature_unit, str) or not temperature_unit.strip():
        raise ThermalModelError(
            "temperature_unit must be a nonempty string"
        )

    ambient, decay, gain = _validate_profile_values(
        ambient_temperature_proxy=package.get(
            "ambient_temperature_proxy"
        ),
        thermal_decay=package.get("thermal_decay"),
        thermal_gain=package.get("thermal_gain"),
    )

    expected_equation = (
        "ambient + (temperature - ambient) * thermal_decay "
        "+ normalized_cycle_cost * thermal_gain"
    )

    if package.get("update_equation") != expected_equation:
        raise ThermalModelError(
            "invalid thermal update equation marker"
        )

    expected_digest = sha256_hex(
        canonical_json_bytes(
            _profile_digest_payload(
                profile_name=profile_name,
                temperature_unit=temperature_unit,
                ambient_temperature_proxy=ambient,
                thermal_decay=decay,
                thermal_gain=gain,
            )
        )
    )

    if package.get("thermal_profile_sha256") != expected_digest:
        raise ThermalModelError(
            "thermal_profile_sha256 mismatch"
        )


def profile_from_package(
    package: Mapping[str, Any],
) -> ThermalProxyProfile:
    validate_thermal_profile_package(package)

    return ThermalProxyProfile(
        profile_name=str(package["profile_name"]),
        temperature_unit=str(package["temperature_unit"]),
        ambient_temperature_proxy=float(
            package["ambient_temperature_proxy"]
        ),
        thermal_decay=float(package["thermal_decay"]),
        thermal_gain=float(package["thermal_gain"]),
        thermal_profile_sha256=str(
            package["thermal_profile_sha256"]
        ),
    )


def load_thermal_profile(
    path: Path,
) -> ThermalProxyProfile:
    try:
        value = json.loads(
            path.read_text(encoding="utf-8")
        )
    except OSError as exc:
        raise ThermalModelError(
            f"unable to read thermal profile: {path}"
        ) from exc
    except json.JSONDecodeError as exc:
        raise ThermalModelError(
            f"invalid thermal profile JSON: {path}"
        ) from exc

    if not isinstance(value, Mapping):
        raise ThermalModelError(
            "thermal-profile JSON must contain an object"
        )

    return profile_from_package(value)


def validate_cycle_costs(
    cycle_normalized_energy: Sequence[Any],
) -> list[float]:
    """Validate a per-cycle normalized activity-cost trace."""

    if isinstance(cycle_normalized_energy, (str, bytes, bytearray)):
        raise ThermalModelError(
            "cycle_normalized_energy must be a numeric sequence"
        )

    if not isinstance(cycle_normalized_energy, Sequence):
        raise ThermalModelError(
            "cycle_normalized_energy must be a sequence"
        )

    validated: list[float] = []

    for index, value in enumerate(cycle_normalized_energy):
        numeric = _finite_number(
            value,
            f"cycle_normalized_energy[{index}]",
        )

        if numeric < 0.0:
            raise ThermalModelError(
                "cycle normalized energy must be nonnegative"
            )

        validated.append(numeric)

    return validated


def thermal_step(
    *,
    temperature_proxy: Any,
    normalized_cycle_cost: Any,
    profile: ThermalProxyProfile,
) -> float:
    """Advance the common thermal proxy by one benchmark cycle."""

    temperature = _finite_number(
        temperature_proxy,
        "temperature_proxy",
    )
    cycle_cost = _finite_number(
        normalized_cycle_cost,
        "normalized_cycle_cost",
    )

    if cycle_cost < 0.0:
        raise ThermalModelError(
            "normalized_cycle_cost must be nonnegative"
        )

    next_temperature = (
        profile.ambient_temperature_proxy
        + (
            temperature
            - profile.ambient_temperature_proxy
        )
        * profile.thermal_decay
        + cycle_cost
        * profile.thermal_gain
    )

    if not math.isfinite(next_temperature):
        raise ThermalModelError(
            "thermal proxy state is not finite"
        )

    return next_temperature


def calculate_thermal_trace(
    cycle_normalized_energy: Sequence[Any],
    profile: ThermalProxyProfile,
) -> dict[str, Any]:
    """Apply the same thermal proxy model to one normalized cost trace."""

    cycle_costs = validate_cycle_costs(
        cycle_normalized_energy
    )

    temperature = profile.ambient_temperature_proxy
    temperatures: list[float] = []

    for cycle_cost in cycle_costs:
        temperature = thermal_step(
            temperature_proxy=temperature,
            normalized_cycle_cost=cycle_cost,
            profile=profile,
        )
        temperatures.append(temperature)

    peak_temperature_proxy = (
        max(
            [profile.ambient_temperature_proxy, *temperatures]
        )
        if temperatures
        else profile.ambient_temperature_proxy
    )

    final_temperature_proxy = (
        temperatures[-1]
        if temperatures
        else profile.ambient_temperature_proxy
    )

    return {
        "schema": THERMAL_RESULT_SCHEMA,
        "suite_name": SUITE_NAME,
        "profile_name": profile.profile_name,
        "temperature_unit": profile.temperature_unit,
        "thermal_profile_sha256": profile.thermal_profile_sha256,
        "cycle_count": len(cycle_costs),
        "ambient_temperature_proxy": (
            profile.ambient_temperature_proxy
        ),
        "thermal_decay": profile.thermal_decay,
        "thermal_gain": profile.thermal_gain,
        "cycle_normalized_energy": cycle_costs,
        "temperature_proxy_trace": temperatures,
        "peak_temperature_proxy": peak_temperature_proxy,
        "final_temperature_proxy": final_temperature_proxy,
    }


def build_demonstration_cost_trace() -> list[float]:
    """Build a small deterministic normalized activity trace."""

    return [
        0.0,
        2.0,
        4.0,
        1.0,
        0.0,
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


def _raises_thermal_error(callback: Any) -> bool:
    try:
        callback()
    except ThermalModelError:
        return True
    return False


def run_self_test() -> dict[str, Any]:
    package_a = build_thermal_profile_package()
    package_b = build_thermal_profile_package()

    profile = profile_from_package(package_a)
    trace = build_demonstration_cost_trace()

    result_a = calculate_thermal_trace(
        trace,
        profile,
    )
    result_b = calculate_thermal_trace(
        trace,
        profile,
    )

    zero_trace_result = calculate_thermal_trace(
        [0.0, 0.0, 0.0],
        profile,
    )

    impulse_profile = profile_from_package(
        build_thermal_profile_package(
            ambient_temperature_proxy=0.0,
            thermal_decay=0.5,
            thermal_gain=1.0,
        )
    )

    impulse_result = calculate_thermal_trace(
        [2.0, 0.0, 0.0],
        impulse_profile,
    )

    expected_impulse = [2.0, 1.0, 0.5]

    tampered_package = json.loads(
        json.dumps(package_a)
    )
    tampered_package["thermal_gain"] = 0.02

    checks = {
        "default_profile_valid": True,
        "deterministic_profile_digest_repeat": (
            package_a["thermal_profile_sha256"]
            == package_b["thermal_profile_sha256"]
        ),
        "deterministic_profile_byte_repeat": (
            canonical_json_bytes(package_a)
            == canonical_json_bytes(package_b)
        ),
        "profile_digest_length_64": (
            len(package_a["thermal_profile_sha256"]) == 64
        ),
        "default_ambient_zero": (
            profile.ambient_temperature_proxy == 0.0
        ),
        "default_decay_095": (
            profile.thermal_decay == 0.95
        ),
        "default_gain_001": (
            profile.thermal_gain == 0.01
        ),
        "deterministic_trace_repeat": (
            result_a == result_b
        ),
        "trace_cycle_count": (
            result_a["cycle_count"] == len(trace)
        ),
        "trace_length_matches_cycle_count": (
            len(result_a["temperature_proxy_trace"])
            == len(trace)
        ),
        "peak_not_below_final": (
            result_a["peak_temperature_proxy"]
            >= result_a["final_temperature_proxy"]
        ),
        "zero_trace_stays_at_ambient": all(
            value == profile.ambient_temperature_proxy
            for value in zero_trace_result[
                "temperature_proxy_trace"
            ]
        ),
        "impulse_response_exact": all(
            math.isclose(
                actual,
                expected,
                rel_tol=0.0,
                abs_tol=1e-12,
            )
            for actual, expected in zip(
                impulse_result["temperature_proxy_trace"],
                expected_impulse,
            )
        ),
        "tampered_profile_digest_rejected": (
            _raises_thermal_error(
                lambda: validate_thermal_profile_package(
                    tampered_package
                )
            )
        ),
        "negative_cycle_cost_rejected": (
            _raises_thermal_error(
                lambda: calculate_thermal_trace(
                    [0.0, -1.0],
                    profile,
                )
            )
        ),
        "nan_cycle_cost_rejected": (
            _raises_thermal_error(
                lambda: calculate_thermal_trace(
                    [float("nan")],
                    profile,
                )
            )
        ),
        "invalid_decay_rejected": (
            _raises_thermal_error(
                lambda: build_thermal_profile_package(
                    thermal_decay=1.0
                )
            )
        ),
        "negative_gain_rejected": (
            _raises_thermal_error(
                lambda: build_thermal_profile_package(
                    thermal_gain=-0.01
                )
            )
        ),
        "negative_ambient_rejected": (
            _raises_thermal_error(
                lambda: build_thermal_profile_package(
                    ambient_temperature_proxy=-1.0
                )
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
        "schema": THERMAL_SELF_TEST_SCHEMA,
        "status": status,
        "check_count": len(checks),
        "checks": checks,
        "default_thermal_profile_sha256": (
            package_a["thermal_profile_sha256"]
        ),
        "default_profile": package_a,
        "demonstration_result": result_a,
        "impulse_response_result": impulse_result,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Apply one shared thermal proxy model "
            "to comparative architecture normalized-cost traces."
        )
    )

    parser.add_argument(
        "--profile",
        type=Path,
        help=(
            "Optional thermal proxy profile JSON path. "
            "The default is common_rc_thermal_proxy_v1."
        ),
    )

    parser.add_argument(
        "--write-default-profile",
        type=Path,
        help=(
            "Write the canonical default thermal "
            "proxy profile JSON package."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Run thermal proxy model self-tests.",
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
            package = build_thermal_profile_package()
            write_json(
                args.write_default_profile,
                package,
            )

        if args.self_test:
            result = run_self_test()
        else:
            profile = (
                load_thermal_profile(args.profile)
                if args.profile
                else profile_from_package(
                    build_thermal_profile_package()
                )
            )

            result = calculate_thermal_trace(
                build_demonstration_cost_trace(),
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
                    "FRP COMPARATIVE THERMAL PROXY MODEL SELF TEST"
                )
                print(f"status={result['status']}")
                print(f"checks={result['check_count']}")
                print(
                    "default_thermal_profile_sha256="
                    f"{result['default_thermal_profile_sha256']}"
                )
            else:
                print(
                    "FRP COMPARATIVE THERMAL PROXY MODEL"
                )
                print(
                    f"profile_name={result['profile_name']}"
                )
                print(
                    "thermal_profile_sha256="
                    f"{result['thermal_profile_sha256']}"
                )
                print(
                    f"cycle_count={result['cycle_count']}"
                )
                print(
                    "peak_temperature_proxy="
                    f"{result['peak_temperature_proxy']}"
                )
                print(
                    "final_temperature_proxy="
                    f"{result['final_temperature_proxy']}"
                )

        return (
            0
            if not args.self_test
            or result["status"] == "PASS"
            else 1
        )

    except ThermalModelError as exc:
        raise SystemExit(
            f"thermal model error: {exc}"
        ) from exc


if __name__ == "__main__":
    raise SystemExit(main())

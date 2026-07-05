#!/usr/bin/env python3
"""Common thermal-ceiling governor for the nonlinear multitask benchmark.

The initial benchmark stage is hard-locked to ``scheduler_mode = free``.
This module reuses the existing architecture-comparison cost and thermal
models. It does not duplicate the FRP kernel, change benchmark coefficients,
or produce architecture rankings.
"""

from __future__ import annotations

import hashlib
import json
import math
import sys
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence


BENCHMARK_SCHEMA = "frp.benchmark.nonlinear_multitask_thermal_ceiling.v1"
TICK_SCHEMA = "frp.benchmark.nonlinear_multitask_thermal_tick.v1"
LOGICAL_UPDATE_SCHEMA = (
    "frp.benchmark.nonlinear_multitask_thermal_logical_update.v1"
)
SUMMARY_SCHEMA = "frp.benchmark.nonlinear_multitask_thermal_summary.v1"

EXPECTED_SCHEDULER_MODE = "free"

EXPECTED_THERMAL_PROFILE_NAME = "common_rc_thermal_proxy_v1"

EXPECTED_COST_PROFILE_NAME = (
    "literature_anchored_cmos45_sensitivity_v1"
)

EXPECTED_COST_SCENARIO = "nominal"

EXPECTED_TEMPERATURE_UNIT = (
    "normalized_temperature_proxy"
)

EXPECTED_THERMAL_CEILING = 1.0

EXPECTED_ACTIVITY_QUANTUM = 4.0

EXPECTED_COOLING_TICK_COST = 0.0

EXPECTED_STATUS_VALUES = (
    "within_ceiling",
    "throttled",
    "ceiling_violation",
)

ARCHITECTURE_COMPARISON_DIR = (
    Path(__file__).resolve().parents[2]
    / "architecture_comparison"
)

if (
    str(
        ARCHITECTURE_COMPARISON_DIR
    )
    not in sys.path
):
    sys.path.insert(
        0,
        str(
            ARCHITECTURE_COMPARISON_DIR
        ),
    )

try:
    from common_cost_model import (
        COST_CLASSES,
        EVENT_FIELDS,
        NormalizedCostProfile,
        build_cost_profile_package,
        calculate_cycle_cost,
        empty_event_counts,
        profile_from_package as cost_profile_from_package,
    )

    from common_thermal_model import (
        ThermalProxyProfile,
        load_thermal_profile,
        thermal_step,
    )

except ImportError as exc:
    raise RuntimeError(
        "unable to import shared architecture-comparison "
        "cost/thermal models"
    ) from exc


class ThermalCeilingError(
    ValueError
):
    """Raised when the common thermal-ceiling contract is violated."""


class ThermalCeilingBudgetExhausted(
    ThermalCeilingError
):
    """Raised when the predeclared benchmark-tick budget is exhausted."""


def fail(
    message: str,
) -> NoReturn:
    raise ThermalCeilingError(
        message
    )


def require(
    condition: bool,
    message: str,
) -> None:
    if not condition:
        fail(
            message
        )


def canonical_json_bytes(
    value: Any,
) -> bytes:
    try:
        encoded = json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(
                ",",
                ":",
            ),
            allow_nan=False,
        )

    except (
        TypeError,
        ValueError,
    ) as exc:
        fail(
            f"unable to canonicalize value: {exc}"
        )

    return encoded.encode(
        "utf-8"
    )


def sha256_hex(
    data: bytes,
) -> str:
    return hashlib.sha256(
        data
    ).hexdigest()


def sha256_file(
    path: Path,
) -> str:
    require(
        path.is_file(),
        f"bound file not found: {path}",
    )

    digest = hashlib.sha256()

    try:
        with path.open(
            "rb"
        ) as handle:
            for chunk in iter(
                lambda: handle.read(
                    1024 * 1024
                ),
                b"",
            ):
                digest.update(
                    chunk
                )

    except OSError as exc:
        fail(
            f"unable to hash bound file {path}: {exc}"
        )

    return digest.hexdigest()


def load_json_object(
    path: Path,
    label: str,
) -> dict[str, Any]:
    require(
        path.is_file(),
        f"{label} file not found: {path}",
    )

    try:
        value = json.loads(
            path.read_text(
                encoding="utf-8"
            )
        )

    except OSError as exc:
        fail(
            f"unable to read {label}: {exc}"
        )

    except json.JSONDecodeError as exc:
        fail(
            f"invalid {label} JSON: {exc}"
        )

    require(
        isinstance(
            value,
            dict,
        ),
        f"{label} root must be an object",
    )

    return value


def require_finite_nonnegative(
    value: Any,
    name: str,
) -> float:
    require(
        not isinstance(
            value,
            bool,
        )
        and isinstance(
            value,
            (
                int,
                float,
            ),
        ),
        f"{name} must be numeric",
    )

    number = float(
        value
    )

    require(
        math.isfinite(
            number
        ),
        f"{name} must be finite",
    )

    require(
        number >= 0.0,
        f"{name} must be nonnegative",
    )

    return number


def require_positive_int(
    value: Any,
    name: str,
) -> int:
    require(
        not isinstance(
            value,
            bool,
        )
        and isinstance(
            value,
            int,
        ),
        f"{name} must be an integer",
    )

    require(
        value > 0,
        f"{name} must be positive",
    )

    return value


def _to_decimal(
    value: float,
    name: str,
) -> Decimal:
    try:
        decimal_value = Decimal(
            str(
                value
            )
        )

    except InvalidOperation as exc:
        fail(
            f"{name} cannot be represented as Decimal: {exc}"
        )

    require(
        decimal_value.is_finite(),
        f"{name} must be finite",
    )

    require(
        decimal_value >= 0,
        f"{name} must be nonnegative",
    )

    return decimal_value


def slice_normalized_activity(
    total_normalized_cost: Any,
    activity_quantum: Any,
) -> tuple[
    float,
    ...,
]:
    """Split one aggregate activity cost into ordered exact quanta/remainder."""

    total = require_finite_nonnegative(
        total_normalized_cost,
        "total_normalized_cost",
    )

    quantum = require_finite_nonnegative(
        activity_quantum,
        "activity_quantum",
    )

    require(
        quantum > 0.0,
        "activity_quantum must be greater than zero",
    )

    if total == 0.0:
        return (
            0.0,
        )

    total_decimal = _to_decimal(
        total,
        "total_normalized_cost",
    )

    quantum_decimal = _to_decimal(
        quantum,
        "activity_quantum",
    )

    full_count = int(
        total_decimal
        // quantum_decimal
    )

    remainder = (
        total_decimal
        - quantum_decimal
        * full_count
    )

    slices = [
        float(
            quantum_decimal
        )
        for _ in range(
            full_count
        )
    ]

    if remainder > 0:
        slices.append(
            float(
                remainder
            )
        )

    require(
        len(
            slices
        )
        > 0,
        "activity slicing produced no slices",
    )

    require(
        all(
            0.0
            <= item
            <= quantum
            for item
            in slices
        ),
        "activity slice exceeds the declared quantum",
    )

    require(
        math.isclose(
            math.fsum(
                slices
            ),
            total,
            rel_tol=0.0,
            abs_tol=1e-12,
        ),
        "activity slices do not preserve total normalized cost",
    )

    return tuple(
        slices
    )


@dataclass(
    frozen=True
)
class ThermalCeilingContext:
    thermal_profile: ThermalProxyProfile

    nominal_cost_profile: NormalizedCostProfile

    thermal_profile_path: str

    thermal_profile_file_sha256: str

    thermal_profile_contract_sha256: str

    cost_profile_path: str

    cost_profile_file_sha256: str

    hardware_sensitivity_profile_name: str

    cost_scenario: str

    thermal_ceiling: float

    activity_quantum: float

    cooling_tick_cost: float

    maximum_benchmark_ticks_per_case: int

    def to_dict(
        self,
    ) -> dict[str, Any]:
        payload = {
            "schema": (
                BENCHMARK_SCHEMA
            ),
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "thermal_profile_path": (
                self.thermal_profile_path
            ),
            "thermal_profile_file_sha256": (
                self.thermal_profile_file_sha256
            ),
            "thermal_profile_name": (
                self.thermal_profile.profile_name
            ),
            "thermal_profile_contract_sha256": (
                self.thermal_profile_contract_sha256
            ),
            "temperature_unit": (
                self.thermal_profile.temperature_unit
            ),
            "ambient_temperature_proxy": (
                self.thermal_profile.ambient_temperature_proxy
            ),
            "thermal_decay": (
                self.thermal_profile.thermal_decay
            ),
            "thermal_gain": (
                self.thermal_profile.thermal_gain
            ),
            "cost_profile_path": (
                self.cost_profile_path
            ),
            "cost_profile_file_sha256": (
                self.cost_profile_file_sha256
            ),
            "hardware_sensitivity_profile_name": (
                self.hardware_sensitivity_profile_name
            ),
            "cost_scenario": (
                self.cost_scenario
            ),
            "nominal_cost_profile_name": (
                self.nominal_cost_profile.profile_name
            ),
            "nominal_cost_profile_sha256": (
                self.nominal_cost_profile.cost_profile_sha256
            ),
            "thermal_ceiling": (
                self.thermal_ceiling
            ),
            "activity_quantum": (
                self.activity_quantum
            ),
            "cooling_tick_cost": (
                self.cooling_tick_cost
            ),
            "maximum_benchmark_ticks_per_case": (
                self.maximum_benchmark_ticks_per_case
            ),
            "cooling_tick_advances_logical_convergence": (
                False
            ),
            "winner_assertions": [],
        }

        payload[
            "thermal_ceiling_contract_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


def validate_workload_thermal_contract(
    workload_profile: Mapping[
        str,
        Any,
    ],
) -> Mapping[
    str,
    Any,
]:
    require(
        isinstance(
            workload_profile,
            Mapping,
        ),
        "workload_profile must be an object",
    )

    require(
        workload_profile.get(
            "scheduler_mode"
        )
        == EXPECTED_SCHEDULER_MODE,
        "initial benchmark scheduler_mode must be free",
    )

    contract = workload_profile.get(
        "thermal_ceiling_contract"
    )

    require(
        isinstance(
            contract,
            Mapping,
        ),
        "thermal_ceiling_contract must be an object",
    )

    exact_values = {
        "thermal_profile_name": (
            EXPECTED_THERMAL_PROFILE_NAME
        ),
        "cost_profile_name": (
            EXPECTED_COST_PROFILE_NAME
        ),
        "cost_scenario": (
            EXPECTED_COST_SCENARIO
        ),
        "temperature_unit": (
            EXPECTED_TEMPERATURE_UNIT
        ),
        "ambient_temperature_proxy": 0.0,
        "thermal_decay": 0.95,
        "thermal_gain": 0.01,
        "thermal_ceiling": (
            EXPECTED_THERMAL_CEILING
        ),
        "normalized_activity_quantum_per_benchmark_tick": (
            EXPECTED_ACTIVITY_QUANTUM
        ),
        "full_quantum_steady_state_temperature_proxy": (
            0.8
        ),
        "cooling_tick_cost": (
            EXPECTED_COOLING_TICK_COST
        ),
        "throttle_policy": (
            "insert_zero_activity_cooling_tick_when_next_activity_quantum_"
            "would_exceed_thermal_ceiling"
        ),
        "resume_condition": (
            "predicted_temperature_after_next_activity_quantum <= "
            "thermal_ceiling"
        ),
        "ceiling_status_values": list(
            EXPECTED_STATUS_VALUES
        ),
        "ceiling_violation_condition": (
            "maximum_benchmark_ticks_per_case_exhausted_before_semantic_"
            "completion"
        ),
    }

    for field, expected in exact_values.items():
        require(
            contract.get(
                field
            )
            == expected,
            f"thermal_ceiling_contract.{field} mismatch",
        )

    require(
        contract.get(
            "activity_slicing_rule"
        )
        == (
            "preserve_declared_event_order_and_split_aggregate_cost_into_"
            "exact_4.0_or_final_remainder_quanta"
        ),
        "thermal_ceiling_contract.activity_slicing_rule mismatch",
    )

    convergence = workload_profile.get(
        "convergence_contract"
    )

    require(
        isinstance(
            convergence,
            Mapping,
        ),
        "convergence_contract must be an object",
    )

    require_positive_int(
        convergence.get(
            "maximum_benchmark_ticks_per_case"
        ),
        "maximum_benchmark_ticks_per_case",
    )

    validation = workload_profile.get(
        "validation_contract"
    )

    require(
        isinstance(
            validation,
            Mapping,
        ),
        "validation_contract must be an object",
    )

    require(
        validation.get(
            "winner_assertions"
        )
        == [],
        "winner_assertions must be empty",
    )

    return contract


def build_thermal_ceiling_context(
    workload_profile: Mapping[
        str,
        Any,
    ],
    repository_root: Path,
) -> ThermalCeilingContext:
    contract = (
        validate_workload_thermal_contract(
            workload_profile
        )
    )

    root = (
        repository_root
        .expanduser()
        .resolve()
    )

    thermal_relative = str(
        contract[
            "thermal_profile_path"
        ]
    )

    cost_relative = str(
        contract[
            "cost_profile_path"
        ]
    )

    thermal_path = (
        root
        / thermal_relative
    )

    cost_path = (
        root
        / cost_relative
    )

    thermal_file_sha256 = sha256_file(
        thermal_path
    )

    cost_file_sha256 = sha256_file(
        cost_path
    )

    require(
        thermal_file_sha256
        == contract[
            "thermal_profile_sha256"
        ],
        "thermal profile file SHA-256 mismatch",
    )

    require(
        cost_file_sha256
        == contract[
            "cost_profile_sha256"
        ],
        "cost profile file SHA-256 mismatch",
    )

    thermal_profile = load_thermal_profile(
        thermal_path
    )

    require(
        thermal_profile.profile_name
        == EXPECTED_THERMAL_PROFILE_NAME,
        "thermal profile name mismatch",
    )

    require(
        thermal_profile.temperature_unit
        == EXPECTED_TEMPERATURE_UNIT,
        "thermal temperature unit mismatch",
    )

    require(
        thermal_profile.ambient_temperature_proxy
        == contract[
            "ambient_temperature_proxy"
        ],
        "thermal ambient mismatch",
    )

    require(
        thermal_profile.thermal_decay
        == contract[
            "thermal_decay"
        ],
        "thermal decay mismatch",
    )

    require(
        thermal_profile.thermal_gain
        == contract[
            "thermal_gain"
        ],
        "thermal gain mismatch",
    )

    hardware_profile = load_json_object(
        cost_path,
        "hardware sensitivity cost profile",
    )

    require(
        hardware_profile.get(
            "profile_name"
        )
        == EXPECTED_COST_PROFILE_NAME,
        "hardware sensitivity profile name mismatch",
    )

    require(
        hardware_profile.get(
            "scenario_order"
        )
        == [
            "lower_bound",
            "nominal",
            "upper_bound",
        ],
        "hardware sensitivity scenario order mismatch",
    )

    require(
        hardware_profile.get(
            "coefficient_order"
        )
        == list(
            COST_CLASSES
        ),
        "hardware sensitivity coefficient order mismatch",
    )

    scenario_vectors = hardware_profile.get(
        "scenario_vectors"
    )

    require(
        isinstance(
            scenario_vectors,
            Mapping,
        ),
        "hardware sensitivity scenario_vectors missing",
    )

    nominal_vector = scenario_vectors.get(
        EXPECTED_COST_SCENARIO
    )

    require(
        isinstance(
            nominal_vector,
            Mapping,
        ),
        "nominal hardware sensitivity scenario missing",
    )

    require(
        list(
            nominal_vector.keys()
        )
        == list(
            COST_CLASSES
        ),
        "nominal cost vector order mismatch",
    )

    nominal_package = build_cost_profile_package(
        profile_name=(
            f"{EXPECTED_COST_PROFILE_NAME}"
            f"::{EXPECTED_COST_SCENARIO}"
        ),
        cost_unit=(
            "normalized_hardware_sensitivity_unit"
        ),
        costs=(
            nominal_vector
        ),
    )

    nominal_cost_profile = (
        cost_profile_from_package(
            nominal_package
        )
    )

    context = ThermalCeilingContext(
        thermal_profile=(
            thermal_profile
        ),
        nominal_cost_profile=(
            nominal_cost_profile
        ),
        thermal_profile_path=(
            thermal_relative
        ),
        thermal_profile_file_sha256=(
            thermal_file_sha256
        ),
        thermal_profile_contract_sha256=(
            thermal_profile.thermal_profile_sha256
        ),
        cost_profile_path=(
            cost_relative
        ),
        cost_profile_file_sha256=(
            cost_file_sha256
        ),
        hardware_sensitivity_profile_name=(
            EXPECTED_COST_PROFILE_NAME
        ),
        cost_scenario=(
            EXPECTED_COST_SCENARIO
        ),
        thermal_ceiling=float(
            contract[
                "thermal_ceiling"
            ]
        ),
        activity_quantum=float(
            contract[
                "normalized_activity_quantum_per_benchmark_tick"
            ]
        ),
        cooling_tick_cost=float(
            contract[
                "cooling_tick_cost"
            ]
        ),
        maximum_benchmark_ticks_per_case=int(
            workload_profile[
                "convergence_contract"
            ][
                "maximum_benchmark_ticks_per_case"
            ]
        ),
    )

    require(
        thermal_step(
            temperature_proxy=(
                context
                .thermal_profile
                .ambient_temperature_proxy
            ),
            normalized_cycle_cost=(
                context.activity_quantum
            ),
            profile=(
                context.thermal_profile
            ),
        )
        <= context.thermal_ceiling,
        "declared activity quantum cannot fit from ambient temperature",
    )

    return context


def normalized_event_cost(
    event_counts: Mapping[
        str,
        Any,
    ],
    context: ThermalCeilingContext,
) -> dict[str, Any]:
    result = calculate_cycle_cost(
        event_counts,
        context.nominal_cost_profile,
    )

    require(
        set(
            result[
                "event_counts"
            ].keys()
        )
        == set(
            EVENT_FIELDS
        ),
        "normalized event-cost result field set mismatch",
    )

    return result


@dataclass(
    frozen=True
)
class ThermalTickRecord:
    benchmark_tick: int

    tick_kind: str

    logical_update_id: str

    packet_index: int | None

    slice_index: int | None

    normalized_activity_cost: float

    temperature_before: float

    temperature_after: float

    thermal_ceiling: float

    logical_update_commit: bool

    logical_convergence_progress: bool

    def to_dict(
        self,
    ) -> dict[str, Any]:
        return {
            "schema": (
                TICK_SCHEMA
            ),
            "benchmark_tick": (
                self.benchmark_tick
            ),
            "tick_kind": (
                self.tick_kind
            ),
            "logical_update_id": (
                self.logical_update_id
            ),
            "packet_index": (
                self.packet_index
            ),
            "slice_index": (
                self.slice_index
            ),
            "normalized_activity_cost": (
                self.normalized_activity_cost
            ),
            "temperature_before": (
                self.temperature_before
            ),
            "temperature_after": (
                self.temperature_after
            ),
            "thermal_ceiling": (
                self.thermal_ceiling
            ),
            "under_ceiling": (
                self.temperature_after
                <= self.thermal_ceiling
            ),
            "logical_update_commit": (
                self.logical_update_commit
            ),
            "logical_convergence_progress": (
                self.logical_convergence_progress
            ),
        }


class CommonThermalCeilingGovernor:
    """Architecture-neutral activity/power governor under one thermal envelope."""

    def __init__(
        self,
        context: ThermalCeilingContext,
    ) -> None:
        self.context = (
            context
        )

        self.temperature_proxy = (
            context
            .thermal_profile
            .ambient_temperature_proxy
        )

        self.benchmark_tick = 0

        self.activity_ticks = 0

        self.cooling_ticks = 0

        self.total_normalized_energy = (
            0.0
        )

        self.peak_temperature_proxy = (
            self.temperature_proxy
        )

        self.records: list[
            ThermalTickRecord
        ] = []

    def _require_tick_budget(
        self,
    ) -> None:
        if (
            self.benchmark_tick
            >= self.context.maximum_benchmark_ticks_per_case
        ):
            raise ThermalCeilingBudgetExhausted(
                "maximum_benchmark_ticks_per_case exhausted"
            )

    def _append_tick(
        self,
        *,
        tick_kind: str,
        logical_update_id: str,
        packet_index: int | None,
        slice_index: int | None,
        normalized_activity_cost: float,
        logical_update_commit: bool,
        logical_convergence_progress: bool,
    ) -> ThermalTickRecord:
        self._require_tick_budget()

        before = (
            self.temperature_proxy
        )

        after = thermal_step(
            temperature_proxy=(
                before
            ),
            normalized_cycle_cost=(
                normalized_activity_cost
            ),
            profile=(
                self.context.thermal_profile
            ),
        )

        require(
            after
            <= self.context.thermal_ceiling
            + 1e-12,
            "thermal governor committed a tick above the ceiling",
        )

        record = ThermalTickRecord(
            benchmark_tick=(
                self.benchmark_tick
            ),
            tick_kind=(
                tick_kind
            ),
            logical_update_id=(
                logical_update_id
            ),
            packet_index=(
                packet_index
            ),
            slice_index=(
                slice_index
            ),
            normalized_activity_cost=(
                normalized_activity_cost
            ),
            temperature_before=(
                before
            ),
            temperature_after=(
                after
            ),
            thermal_ceiling=(
                self.context.thermal_ceiling
            ),
            logical_update_commit=(
                logical_update_commit
            ),
            logical_convergence_progress=(
                logical_convergence_progress
            ),
        )

        self.records.append(
            record
        )

        self.temperature_proxy = (
            after
        )

        self.peak_temperature_proxy = max(
            self.peak_temperature_proxy,
            after,
        )

        self.benchmark_tick += 1

        if tick_kind == "activity":
            self.activity_ticks += 1

            self.total_normalized_energy = (
                math.fsum(
                    [
                        self.total_normalized_energy,
                        normalized_activity_cost,
                    ]
                )
            )

        elif tick_kind == "cooling":
            self.cooling_ticks += 1

        else:
            fail(
                f"unknown tick_kind: {tick_kind}"
            )

        return record

    def _cool_until_slice_fits(
        self,
        *,
        logical_update_id: str,
        next_slice_cost: float,
    ) -> list[
        ThermalTickRecord
    ]:
        cooling_records: list[
            ThermalTickRecord
        ] = []

        while True:
            predicted = thermal_step(
                temperature_proxy=(
                    self.temperature_proxy
                ),
                normalized_cycle_cost=(
                    next_slice_cost
                ),
                profile=(
                    self.context.thermal_profile
                ),
            )

            if (
                predicted
                <= self.context.thermal_ceiling
                + 1e-12
            ):
                return cooling_records

            cooling_records.append(
                self._append_tick(
                    tick_kind=(
                        "cooling"
                    ),
                    logical_update_id=(
                        logical_update_id
                    ),
                    packet_index=(
                        None
                    ),
                    slice_index=(
                        None
                    ),
                    normalized_activity_cost=(
                        self.context.cooling_tick_cost
                    ),
                    logical_update_commit=(
                        False
                    ),
                    logical_convergence_progress=(
                        False
                    ),
                )
            )

    def execute_logical_update(
        self,
        *,
        logical_update_id: str,
        event_packets: Sequence[
            Mapping[
                str,
                Any,
            ]
        ],
    ) -> dict[str, Any]:
        require(
            isinstance(
                logical_update_id,
                str,
            )
            and logical_update_id,
            "logical_update_id must be a nonempty string",
        )

        require(
            not isinstance(
                event_packets,
                (
                    str,
                    bytes,
                    bytearray,
                ),
            )
            and isinstance(
                event_packets,
                Sequence,
            ),
            "event_packets must be a sequence",
        )

        packets = list(
            event_packets
        )

        require(
            len(
                packets
            )
            > 0,
            "event_packets must not be empty",
        )

        start_tick = (
            self.benchmark_tick
        )

        start_activity_ticks = (
            self.activity_ticks
        )

        start_cooling_ticks = (
            self.cooling_ticks
        )

        start_energy = (
            self.total_normalized_energy
        )

        start_record_index = len(
            self.records
        )

        planned: list[
            tuple[
                int,
                int,
                float,
            ]
        ] = []

        packet_costs: list[
            dict[str, Any]
        ] = []

        for (
            packet_index,
            event_counts,
        ) in enumerate(
            packets
        ):
            cost_result = (
                normalized_event_cost(
                    event_counts,
                    self.context,
                )
            )

            packet_costs.append(
                cost_result
            )

            slices = (
                slice_normalized_activity(
                    cost_result[
                        "normalized_cycle_cost"
                    ],
                    self.context.activity_quantum,
                )
            )

            for (
                slice_index,
                slice_cost,
            ) in enumerate(
                slices
            ):
                planned.append(
                    (
                        packet_index,
                        slice_index,
                        slice_cost,
                    )
                )

        require(
            len(
                planned
            )
            > 0,
            "logical update produced no thermal activity plan",
        )

        for (
            plan_index,
            (
                packet_index,
                slice_index,
                slice_cost,
            ),
        ) in enumerate(
            planned
        ):
            self._cool_until_slice_fits(
                logical_update_id=(
                    logical_update_id
                ),
                next_slice_cost=(
                    slice_cost
                ),
            )

            is_final_slice = (
                plan_index
                == len(
                    planned
                )
                - 1
            )

            self._append_tick(
                tick_kind=(
                    "activity"
                ),
                logical_update_id=(
                    logical_update_id
                ),
                packet_index=(
                    packet_index
                ),
                slice_index=(
                    slice_index
                ),
                normalized_activity_cost=(
                    slice_cost
                ),
                logical_update_commit=(
                    is_final_slice
                ),
                logical_convergence_progress=(
                    is_final_slice
                ),
            )

        update_records = [
            record.to_dict()
            for record
            in self.records[
                start_record_index:
            ]
        ]

        result: dict[
            str,
            Any,
        ] = {
            "schema": (
                LOGICAL_UPDATE_SCHEMA
            ),
            "logical_update_id": (
                logical_update_id
            ),
            "benchmark_tick_start": (
                start_tick
            ),
            "benchmark_tick_end_inclusive": (
                self.benchmark_tick
                - 1
            ),
            "benchmark_ticks_consumed": (
                self.benchmark_tick
                - start_tick
            ),
            "activity_ticks_consumed": (
                self.activity_ticks
                - start_activity_ticks
            ),
            "cooling_ticks_consumed": (
                self.cooling_ticks
                - start_cooling_ticks
            ),
            "normalized_energy_consumed": (
                math.fsum(
                    [
                        self.total_normalized_energy,
                        -start_energy,
                    ]
                )
            ),
            "packet_count": (
                len(
                    packets
                )
            ),
            "packet_normalized_costs": [
                row[
                    "normalized_cycle_cost"
                ]
                for row
                in packet_costs
            ],
            "logical_convergence_progress_ticks": (
                sum(
                    1
                    for row
                    in update_records
                    if row[
                        "logical_convergence_progress"
                    ]
                )
            ),
            "temperature_after": (
                self.temperature_proxy
            ),
            "peak_temperature_proxy": (
                self.peak_temperature_proxy
            ),
            "thermal_ceiling": (
                self.context.thermal_ceiling
            ),
            "thermal_ceiling_status": (
                "throttled"
                if (
                    self.cooling_ticks
                    > start_cooling_ticks
                )
                else "within_ceiling"
            ),
            "ticks": (
                update_records
            ),
            "winner_assertions": [],
        }

        require(
            result[
                "logical_convergence_progress_ticks"
            ]
            == 1,
            "each logical update must advance convergence exactly once",
        )

        result[
            "logical_update_thermal_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                result
            )
        )

        return result

    def thermal_ceiling_status(
        self,
        *,
        semantic_complete: bool,
        benchmark_tick_budget_exhausted: bool,
    ) -> str:
        require(
            isinstance(
                semantic_complete,
                bool,
            ),
            "semantic_complete must be boolean",
        )

        require(
            isinstance(
                benchmark_tick_budget_exhausted,
                bool,
            ),
            "benchmark_tick_budget_exhausted must be boolean",
        )

        if (
            benchmark_tick_budget_exhausted
            and not semantic_complete
        ):
            return (
                "ceiling_violation"
            )

        if self.cooling_ticks > 0:
            return (
                "throttled"
            )

        return (
            "within_ceiling"
        )

    def summary(
        self,
        *,
        semantic_complete: bool,
        benchmark_tick_budget_exhausted: bool = False,
    ) -> dict[str, Any]:
        status = (
            self.thermal_ceiling_status(
                semantic_complete=(
                    semantic_complete
                ),
                benchmark_tick_budget_exhausted=(
                    benchmark_tick_budget_exhausted
                ),
            )
        )

        payload: dict[
            str,
            Any,
        ] = {
            "schema": (
                SUMMARY_SCHEMA
            ),
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "thermal_profile_name": (
                self.context
                .thermal_profile
                .profile_name
            ),
            "cost_profile_name": (
                self.context
                .hardware_sensitivity_profile_name
            ),
            "cost_scenario": (
                self.context.cost_scenario
            ),
            "thermal_ceiling": (
                self.context.thermal_ceiling
            ),
            "activity_quantum": (
                self.context.activity_quantum
            ),
            "benchmark_ticks": (
                self.benchmark_tick
            ),
            "activity_ticks": (
                self.activity_ticks
            ),
            "thermal_throttle_ticks": (
                self.cooling_ticks
            ),
            "total_normalized_energy": (
                self.total_normalized_energy
            ),
            "peak_temperature_proxy": (
                self.peak_temperature_proxy
            ),
            "final_temperature_proxy": (
                self.temperature_proxy
            ),
            "thermal_ceiling_status": (
                status
            ),
            "semantic_complete": (
                semantic_complete
            ),
            "cooling_ticks_advance_logical_convergence": (
                False
            ),
            "winner_assertions": [],
        }

        payload[
            "thermal_trace_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                [
                    record.to_dict()
                    for record
                    in self.records
                ]
            )
        )

        payload[
            "thermal_summary_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


def build_empty_event_packet(
) -> dict[str, int]:
    return empty_event_counts()


def run_self_test(
    workload_profile: Mapping[
        str,
        Any,
    ],
    repository_root: Path,
) -> dict[str, Any]:
    context = (
        build_thermal_ceiling_context(
            workload_profile,
            repository_root,
        )
    )

    require(
        slice_normalized_activity(
            10.0,
            4.0,
        )
        == (
            4.0,
            4.0,
            2.0,
        ),
        "activity slicing self-test failed",
    )

    packet_a = (
        build_empty_event_packet()
    )

    packet_a[
        "fixed_point_adds_32"
    ] = 10

    packet_b = (
        build_empty_event_packet()
    )

    packet_b[
        "control_events"
    ] = 1

    governor_a = (
        CommonThermalCeilingGovernor(
            context
        )
    )

    governor_b = (
        CommonThermalCeilingGovernor(
            context
        )
    )

    result_a = (
        governor_a.execute_logical_update(
            logical_update_id=(
                "self-test-0"
            ),
            event_packets=[
                packet_a,
                packet_b,
            ],
        )
    )

    result_b = (
        governor_b.execute_logical_update(
            logical_update_id=(
                "self-test-0"
            ),
            event_packets=[
                packet_a,
                packet_b,
            ],
        )
    )

    require(
        result_a
        == result_b,
        "repeated logical thermal execution is not deterministic",
    )

    require(
        result_a[
            "logical_convergence_progress_ticks"
        ]
        == 1,
        "logical convergence must advance exactly once per logical update",
    )

    require(
        result_a[
            "cooling_ticks_consumed"
        ]
        == 0,
        "canonical full-quantum steady-state envelope should not throttle "
        "this self-test trace",
    )

    test_context = (
        ThermalCeilingContext(
            thermal_profile=(
                context.thermal_profile
            ),
            nominal_cost_profile=(
                context.nominal_cost_profile
            ),
            thermal_profile_path=(
                context.thermal_profile_path
            ),
            thermal_profile_file_sha256=(
                context.thermal_profile_file_sha256
            ),
            thermal_profile_contract_sha256=(
                context.thermal_profile_contract_sha256
            ),
            cost_profile_path=(
                context.cost_profile_path
            ),
            cost_profile_file_sha256=(
                context.cost_profile_file_sha256
            ),
            hardware_sensitivity_profile_name=(
                context.hardware_sensitivity_profile_name
            ),
            cost_scenario=(
                context.cost_scenario
            ),
            thermal_ceiling=(
                0.05
            ),
            activity_quantum=(
                context.activity_quantum
            ),
            cooling_tick_cost=(
                context.cooling_tick_cost
            ),
            maximum_benchmark_ticks_per_case=(
                1024
            ),
        )
    )

    throttled_governor = (
        CommonThermalCeilingGovernor(
            test_context
        )
    )

    throttle_packet = (
        build_empty_event_packet()
    )

    throttle_packet[
        "fixed_point_adds_32"
    ] = 4

    first = (
        throttled_governor
        .execute_logical_update(
            logical_update_id=(
                "throttle-0"
            ),
            event_packets=[
                throttle_packet
            ],
        )
    )

    second = (
        throttled_governor
        .execute_logical_update(
            logical_update_id=(
                "throttle-1"
            ),
            event_packets=[
                throttle_packet
            ],
        )
    )

    require(
        first[
            "cooling_ticks_consumed"
        ]
        == 0,
        "first throttling self-test update should fit",
    )

    require(
        second[
            "cooling_ticks_consumed"
        ]
        > 0,
        "second throttling self-test update should require cooling",
    )

    require(
        all(
            not tick[
                "logical_convergence_progress"
            ]
            for tick
            in second[
                "ticks"
            ]
            if tick[
                "tick_kind"
            ]
            == "cooling"
        ),
        "cooling ticks must not advance logical convergence",
    )

    summary_a = (
        governor_a.summary(
            semantic_complete=(
                True
            )
        )
    )

    summary_b = (
        governor_b.summary(
            semantic_complete=(
                True
            )
        )
    )

    require(
        summary_a
        == summary_b,
        "repeated thermal summary is not deterministic",
    )

    contract_a = (
        context.to_dict()
    )

    contract_b = (
        context.to_dict()
    )

    require(
        contract_a
        == contract_b,
        "thermal ceiling contract summary is not deterministic",
    )

    return {
        "status": "PASS",
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "thermal_ceiling": (
            context.thermal_ceiling
        ),
        "activity_quantum": (
            context.activity_quantum
        ),
        "cost_scenario": (
            context.cost_scenario
        ),
        "canonical_trace_sha256": (
            summary_a[
                "thermal_trace_sha256"
            ]
        ),
        "throttling_self_test_cooling_ticks": (
            second[
                "cooling_ticks_consumed"
            ]
        ),
        "cooling_ticks_advance_logical_convergence": (
            False
        ),
        "thermal_ceiling_contract_sha256": (
            contract_a[
                "thermal_ceiling_contract_sha256"
            ]
        ),
        "winner_assertions": [],
    }

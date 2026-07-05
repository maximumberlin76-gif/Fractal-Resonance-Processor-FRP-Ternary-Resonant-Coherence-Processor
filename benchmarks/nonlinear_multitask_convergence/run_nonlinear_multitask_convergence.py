#!/usr/bin/env python3
"""Run the FRP nonlinear multitask convergence benchmark.

The canonical stage is hard-locked to ``scheduler_mode = free``. The runner
executes the predeclared 36-case workload across the four declared
architectures, applies one shared thermal ceiling and one shared convergence
contract, compares completed semantic outputs against the architecture-neutral
shared-problem oracle, derives concurrency-scaling metrics, and emits one
machine-readable deterministic result package. It does not enable 7/1 or 1/7
scheduler modulation and does not assert a winner.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence

SCRIPT_PATH = Path(__file__).resolve()
SCRIPT_DIR = SCRIPT_PATH.parent
REPOSITORY_ROOT = SCRIPT_DIR.parents[1]
ADAPTER_DIR = SCRIPT_DIR / "adapters"
ARCHITECTURE_COMPARISON_DIR = (
    REPOSITORY_ROOT
    / "benchmarks"
    / "architecture_comparison"
)

for import_path in (
    REPOSITORY_ROOT,
    ARCHITECTURE_COMPARISON_DIR,
    ADAPTER_DIR,
    SCRIPT_DIR,
):
    if str(import_path) not in sys.path:
        sys.path.insert(
            0,
            str(import_path),
        )

try:
    from validate_nonlinear_multitask_workload import (
        load_json_object,
        validate_profile,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the nonlinear multitask workload validator"
    ) from exc

try:
    from common_cost_model import (
        EVENT_FIELDS,
        empty_event_counts,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the common architecture-comparison cost model"
    ) from exc

try:
    from common_nonlinear_domain import (
        build_case_initializations,
        build_initialization_manifest,
        gamma_noise_targets_q16,
    )
    from common_nonlinear_problem import (
        build_problem_contract_summary,
        build_problem_state,
        step_problem_domain,
    )
    from common_convergence_contract import (
        CaseConvergenceTracker,
        ConvergenceThresholds,
        build_convergence_contract_summary,
        compare_semantic_outputs,
        ranking_eligibility,
    )
    from common_thermal_ceiling import (
        CommonThermalCeilingGovernor,
        ThermalCeilingBudgetExhausted,
        build_thermal_ceiling_context,
        normalized_event_cost,
        slice_normalized_activity,
        thermal_step,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the shared nonlinear multitask contracts"
    ) from exc

try:
    from binary_synchronous_adapter import (
        BinarySynchronousAdapter,
        build_binary_synchronous_contract,
    )
    from binary_clock_gated_adapter import (
        BinaryClockGatedAdapter,
        build_binary_clock_gated_contract,
    )
    from direct_ternary_adapter import (
        DirectTernaryAdapter,
        build_direct_ternary_contract,
    )
    from frp_v1_7_0_adapter import (
        FRPv170NonlinearMultitaskAdapter,
        build_frp_v1_7_0_contract,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import one or more nonlinear multitask "
        "architecture adapters"
    ) from exc

RESULT_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_convergence_result.v1"
)

CASE_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_convergence_case.v1"
)

ARCHITECTURE_CASE_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_architecture_case_result.v1"
)

TERMINAL_QUIESCENCE_THERMAL_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_terminal_quiescence_thermal_update.v1"
)

ORACLE_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_semantic_oracle.v1"
)

SELF_TEST_SCHEMA = (
    "frp.benchmark."
    "nonlinear_multitask_runner.self_test.v1"
)

BENCHMARK_ID = (
    "nonlinear_multitask_"
    "phase_coherence_convergence_v1"
)

SEMANTIC_REFERENCE_ID = (
    "shared_problem_oracle_v1"
)

EXPECTED_SCHEDULER_MODE = "free"

EXPECTED_ARCHITECTURE_ORDER = (
    "binary_synchronous_reference",
    "binary_clock_gated_reference",
    "direct_ternary_reference",
    "frp_v1_7_0_quantized_shadow",
)

DEFAULT_PROFILE_RELATIVE = (
    "benchmarks/"
    "nonlinear_multitask_convergence/"
    "workloads/"
    "nonlinear_multitask_workload_v1.json"
)

DEFAULT_RESULT_RELATIVE = (
    "benchmarks/"
    "nonlinear_multitask_convergence/"
    "results/"
    "reference_nonlinear_multitask_seed_76.json"
)


class NonlinearMultitaskRunnerError(
    ValueError
):
    """Raised when the canonical runner contract is violated."""


def fail(
    message: str,
) -> NoReturn:
    raise NonlinearMultitaskRunnerError(
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


def pretty_json_text(
    value: Any,
) -> str:
    try:
        return (
            json.dumps(
                value,
                ensure_ascii=False,
                sort_keys=True,
                indent=2,
                allow_nan=False,
            )
            + "\n"
        )
    except (
        TypeError,
        ValueError,
    ) as exc:
        fail(
            f"unable to serialize result package: {exc}"
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
        f"source binding file not found: {path}",
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
            f"unable to hash source binding {path}: {exc}"
        )

    return digest.hexdigest()


def aggregate_event_packets(
    totals: dict[
        str,
        int,
    ],
    event_packets: Sequence[
        Mapping[
            str,
            Any,
        ]
    ],
) -> None:
    require(
        set(
            totals.keys()
        )
        == set(
            EVENT_FIELDS
        ),
        "aggregate event counter field set mismatch",
    )

    for packet in event_packets:
        require(
            set(
                packet.keys()
            )
            == set(
                EVENT_FIELDS
            ),
            "architecture event packet field set mismatch",
        )

        for field in EVENT_FIELDS:
            value = packet[
                field
            ]

            require(
                not isinstance(
                    value,
                    bool,
                )
                and isinstance(
                    value,
                    int,
                )
                and value >= 0,
                f"event field {field} "
                "must be a nonnegative integer",
            )

            totals[
                field
            ] += value


def package_with_sha256(
    payload: Mapping[
        str,
        Any,
    ],
    field: str,
) -> dict[
    str,
    Any,
]:
    result = copy.deepcopy(
        dict(
            payload
        )
    )

    require(
        field
        not in result,
        f"digest field already present: {field}",
    )

    result[
        field
    ] = sha256_hex(
        canonical_json_bytes(
            result
        )
    )

    return result


@dataclass(
    frozen=True
)
class ArchitectureSpec:
    architecture_id: str

    architecture_name: str

    adapter_class: type

    contract_builder: Any

    source_relative_path: str

    is_frp: bool


ARCHITECTURE_SPECS = (
    ArchitectureSpec(
        architecture_id=(
            "binary_synchronous_reference"
        ),
        architecture_name=(
            "Binary Synchronous Reference"
        ),
        adapter_class=(
            BinarySynchronousAdapter
        ),
        contract_builder=(
            build_binary_synchronous_contract
        ),
        source_relative_path=(
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "binary_synchronous_adapter.py"
        ),
        is_frp=False,
    ),
    ArchitectureSpec(
        architecture_id=(
            "binary_clock_gated_reference"
        ),
        architecture_name=(
            "Binary Clock-Gated Reference"
        ),
        adapter_class=(
            BinaryClockGatedAdapter
        ),
        contract_builder=(
            build_binary_clock_gated_contract
        ),
        source_relative_path=(
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "binary_clock_gated_adapter.py"
        ),
        is_frp=False,
    ),
    ArchitectureSpec(
        architecture_id=(
            "direct_ternary_reference"
        ),
        architecture_name=(
            "Direct Ternary Reference"
        ),
        adapter_class=(
            DirectTernaryAdapter
        ),
        contract_builder=(
            build_direct_ternary_contract
        ),
        source_relative_path=(
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "direct_ternary_adapter.py"
        ),
        is_frp=False,
    ),
    ArchitectureSpec(
        architecture_id=(
            "frp_v1_7_0_quantized_shadow"
        ),
        architecture_name=(
            "FRP v1.7.0 Quantized "
            "Hardware Shadow Reference"
        ),
        adapter_class=(
            FRPv170NonlinearMultitaskAdapter
        ),
        contract_builder=(
            build_frp_v1_7_0_contract
        ),
        source_relative_path=(
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "frp_v1_7_0_adapter.py"
        ),
        is_frp=True,
    ),
)


def validate_runner_contract(
    profile: Mapping[
        str,
        Any,
    ],
) -> None:
    require(
        tuple(
            profile.get(
                "architecture_order",
                (),
            )
        )
        == EXPECTED_ARCHITECTURE_ORDER,
        "architecture_order mismatch",
    )

    require(
        tuple(
            spec.architecture_id
            for spec
            in ARCHITECTURE_SPECS
        )
        == EXPECTED_ARCHITECTURE_ORDER,
        "runner architecture registry order mismatch",
    )

    require(
        profile.get(
            "scheduler_mode"
        )
        == EXPECTED_SCHEDULER_MODE,
        "canonical runner scheduler_mode must be free",
    )

    require(
        profile.get(
            "validation_contract",
            {},
        ).get(
            "winner_assertions"
        )
        == [],
        "winner_assertions must remain empty",
    )


def build_source_bindings(
    profile_path: Path,
) -> dict[
    str,
    Any,
]:
    relative_paths = (
        str(
            profile_path.relative_to(
                REPOSITORY_ROOT
            )
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "validate_nonlinear_multitask_workload.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "run_nonlinear_multitask_convergence.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "common_nonlinear_domain.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "common_nonlinear_problem.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "common_convergence_contract.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "common_thermal_ceiling.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "binary_synchronous_adapter.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "binary_clock_gated_adapter.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "direct_ternary_adapter.py"
        ),
        (
            "benchmarks/"
            "nonlinear_multitask_convergence/"
            "adapters/"
            "frp_v1_7_0_adapter.py"
        ),
        (
            "benchmarks/"
            "architecture_comparison/"
            "common_cost_model.py"
        ),
        (
            "benchmarks/"
            "architecture_comparison/"
            "common_thermal_model.py"
        ),
        (
            "benchmarks/"
            "architecture_comparison/"
            "profiles/"
            "thermal_proxy_profile_v1.json"
        ),
        (
            "benchmarks/"
            "architecture_comparison/"
            "profiles/"
            "hardware_sensitivity_cost_profile_v1.json"
        ),
        (
            "frp_prototype_v1_7_0.py"
        ),
    )

    files = [
        {
            "path": (
                relative_path
            ),
            "sha256": (
                sha256_file(
                    REPOSITORY_ROOT
                    / relative_path
                )
            ),
        }
        for relative_path
        in relative_paths
    ]

    payload = {
        "algorithm": (
            "sha256"
        ),
        "files": (
            files
        ),
    }

    return package_with_sha256(
        payload,
        "source_binding_package_sha256",
    )


def build_architecture_contracts(
    profile: Mapping[
        str,
        Any,
    ],
) -> list[
    dict[
        str,
        Any,
    ]
]:
    contracts = []

    for spec in ARCHITECTURE_SPECS:
        contract = (
            spec.contract_builder(
                profile
            )
        )

        contracts.append(
            {
                "architecture_id": (
                    spec.architecture_id
                ),
                "architecture_name": (
                    spec.architecture_name
                ),
                "adapter_source_path": (
                    spec.source_relative_path
                ),
                "adapter_source_sha256": (
                    sha256_file(
                        REPOSITORY_ROOT
                        / spec.source_relative_path
                    )
                ),
                "contract": (
                    contract
                ),
            }
        )

    return contracts


def estimate_thermal_execution(
    governor: CommonThermalCeilingGovernor,
    event_packets: Sequence[
        Mapping[
            str,
            Any,
        ]
    ],
) -> dict[
    str,
    Any,
]:
    temperature = float(
        governor.temperature_proxy
    )

    required_ticks = 0
    activity_ticks = 0
    cooling_ticks = 0

    packet_costs: list[
        float
    ] = []

    for packet in event_packets:
        cost_result = (
            normalized_event_cost(
                packet,
                governor.context,
            )
        )

        packet_cost = float(
            cost_result[
                "normalized_cycle_cost"
            ]
        )

        packet_costs.append(
            packet_cost
        )

        slices = (
            slice_normalized_activity(
                packet_cost,
                governor.context.activity_quantum,
            )
        )

        for slice_cost in slices:
            while True:
                predicted = thermal_step(
                    temperature_proxy=(
                        temperature
                    ),
                    normalized_cycle_cost=(
                        slice_cost
                    ),
                    profile=(
                        governor.context.thermal_profile
                    ),
                )

                if (
                    predicted
                    <= governor.context.thermal_ceiling
                    + 1e-12
                ):
                    break

                cooled = thermal_step(
                    temperature_proxy=(
                        temperature
                    ),
                    normalized_cycle_cost=(
                        governor.context.cooling_tick_cost
                    ),
                    profile=(
                        governor.context.thermal_profile
                    ),
                )

                require(
                    cooled
                    < temperature
                    or math.isclose(
                        cooled,
                        (
                            governor
                            .context
                            .thermal_profile
                            .ambient_temperature_proxy
                        ),
                        rel_tol=0.0,
                        abs_tol=1e-15,
                    ),
                    (
                        "thermal preflight cannot cool enough "
                        "for the next slice"
                    ),
                )

                temperature = (
                    cooled
                )

                required_ticks += 1
                cooling_ticks += 1

            temperature = (
                predicted
            )

            required_ticks += 1
            activity_ticks += 1

    return {
        "required_ticks": (
            required_ticks
        ),
        "activity_ticks": (
            activity_ticks
        ),
        "cooling_ticks": (
            cooling_ticks
        ),
        "packet_normalized_costs": (
            packet_costs
        ),
        "temperature_after": (
            temperature
        ),
    }


def feed_thermal_update_into_convergence(
    tracker: CaseConvergenceTracker,
    *,
    domain_index: int,
    logical_iteration: int,
    semantic_states: Sequence[
        int
    ],
    phase_words: Sequence[
        int
    ],
    thermal_update: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
] | None:
    final_snapshot = None

    for tick_row in thermal_update[
        "ticks"
    ]:
        observations: dict[
            int,
            Mapping[
                str,
                Any,
            ],
        ] = {}

        if tick_row[
            "logical_convergence_progress"
        ]:
            observations[
                domain_index
            ] = {
                "logical_iteration": (
                    logical_iteration
                ),
                "semantic_states": (
                    semantic_states
                ),
                "phase_words": (
                    phase_words
                ),
            }

        snapshots = (
            tracker.observe_tick(
                benchmark_tick=(
                    tick_row[
                        "benchmark_tick"
                    ]
                ),
                domain_observations=(
                    observations
                ),
            )
        )

        if (
            domain_index
            in snapshots
        ):
            final_snapshot = (
                snapshots[
                    domain_index
                ].to_dict()
            )

    require(
        final_snapshot
        is not None,
        (
            "completed thermal logical update "
            "did not advance convergence"
        ),
    )

    return final_snapshot


def compact_thermal_update(
    thermal_update: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
]:
    result = copy.deepcopy(
        dict(
            thermal_update
        )
    )

    result.pop(
        "ticks",
        None,
    )

    return result


def build_trace_row(
    *,
    step_payload: Mapping[
        str,
        Any,
    ],
    thermal_update: Mapping[
        str,
        Any,
    ],
    convergence_snapshot: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
]:
    metadata = copy.deepcopy(
        dict(
            step_payload[
                "logical_update_metadata"
            ]
        )
    )

    payload: dict[
        str,
        Any,
    ] = {
        "domain_index": (
            metadata[
                "domain_index"
            ]
        ),
        "logical_iteration": (
            metadata[
                "logical_iteration_before"
            ]
        ),
        "semantic_states": (
            copy.deepcopy(
                step_payload[
                    "semantic_states"
                ]
            )
        ),
        "phase_words": (
            copy.deepcopy(
                step_payload[
                    "phase_words"
                ]
            )
        ),
        "event_packets": (
            copy.deepcopy(
                step_payload[
                    "event_packets"
                ]
            )
        ),
        "architecture_metadata": (
            metadata
        ),
        "adapter_step_sha256": (
            step_payload[
                "adapter_step_sha256"
            ]
        ),
        "thermal_update": (
            compact_thermal_update(
                thermal_update
            )
        ),
        "convergence_observation": (
            copy.deepcopy(
                dict(
                    convergence_snapshot
                )
            )
        ),
    }

    return package_with_sha256(
        payload,
        "trace_row_sha256",
    )


def execute_terminal_quiescence_thermal_update(
    governor: CommonThermalCeilingGovernor,
    *,
    terminal_update_id: str,
    event_packets: Sequence[
        Mapping[
            str,
            Any,
        ]
    ],
) -> dict[
    str,
    Any,
]:
    require(
        isinstance(
            terminal_update_id,
            str,
        )
        and terminal_update_id,
        "terminal_update_id must be a nonempty string",
    )

    packets = list(
        event_packets
    )

    require(
        len(
            packets
        )
        > 0,
        "terminal quiescence event_packets must not be empty",
    )

    preflight = (
        estimate_thermal_execution(
            governor,
            packets,
        )
    )

    remaining_ticks = (
        governor.context
        .maximum_benchmark_ticks_per_case
        - governor.benchmark_tick
    )

    require(
        preflight[
            "required_ticks"
        ]
        <= remaining_ticks,
        "terminal quiescence exceeds the remaining "
        "benchmark-tick budget",
    )

    start_tick = (
        governor.benchmark_tick
    )

    start_activity_ticks = (
        governor.activity_ticks
    )

    start_cooling_ticks = (
        governor.cooling_ticks
    )

    start_energy = (
        governor.total_normalized_energy
    )

    start_record_index = len(
        governor.records
    )

    planned: list[
        tuple[
            int,
            int,
            float,
        ]
    ] = []

    packet_costs: list[
        dict[
            str,
            Any,
        ]
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
                governor.context,
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
                governor.context.activity_quantum,
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
        "terminal quiescence produced no thermal activity plan",
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
        governor._cool_until_slice_fits(
            logical_update_id=(
                terminal_update_id
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

        governor._append_tick(
            tick_kind=(
                "activity"
            ),
            logical_update_id=(
                terminal_update_id
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
                False
            ),
        )

    update_records = [
        record.to_dict()
        for record
        in governor.records[
            start_record_index:
        ]
    ]

    result: dict[
        str,
        Any,
    ] = {
        "schema": (
            TERMINAL_QUIESCENCE_THERMAL_SCHEMA
        ),
        "terminal_update_id": (
            terminal_update_id
        ),
        "benchmark_tick_start": (
            start_tick
        ),
        "benchmark_tick_end_inclusive": (
            governor.benchmark_tick
            - 1
        ),
        "benchmark_ticks_consumed": (
            governor.benchmark_tick
            - start_tick
        ),
        "activity_ticks_consumed": (
            governor.activity_ticks
            - start_activity_ticks
        ),
        "cooling_ticks_consumed": (
            governor.cooling_ticks
            - start_cooling_ticks
        ),
        "normalized_energy_consumed": (
            math.fsum(
                [
                    governor.total_normalized_energy,
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
            0
        ),
        "terminal_quiescence": (
            True
        ),
        "advances_logical_workload": (
            False
        ),
        "temperature_after": (
            governor.temperature_proxy
        ),
        "peak_temperature_proxy": (
            governor.peak_temperature_proxy
        ),
        "thermal_ceiling": (
            governor.context.thermal_ceiling
        ),
        "thermal_ceiling_status": (
            "throttled"
            if (
                governor.cooling_ticks
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
            "benchmark_ticks_consumed"
        ]
        == preflight[
            "required_ticks"
        ],
        "terminal quiescence thermal preflight tick count diverged",
    )

    require(
        result[
            "activity_ticks_consumed"
        ]
        == preflight[
            "activity_ticks"
        ],
        "terminal quiescence thermal preflight activity count diverged",
    )

    require(
        result[
            "cooling_ticks_consumed"
        ]
        == preflight[
            "cooling_ticks"
        ],
        "terminal quiescence thermal preflight cooling count diverged",
    )

    require(
        math.isclose(
            result[
                "temperature_after"
            ],
            preflight[
                "temperature_after"
            ],
            rel_tol=0.0,
            abs_tol=1e-12,
        ),
        "terminal quiescence thermal preflight final temperature diverged",
    )

    require(
        all(
            row[
                "logical_convergence_progress"
            ]
            is False
            for row
            in update_records
        ),
        "terminal quiescence advanced logical convergence",
    )

    result[
        "terminal_quiescence_thermal_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            result
        )
    )

    return result


def build_terminal_quiescence_trace_row(
    *,
    step_payload: Mapping[
        str,
        Any,
    ],
    thermal_update: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
]:
    metadata = copy.deepcopy(
        dict(
            step_payload[
                "logical_update_metadata"
            ]
        )
    )

    require(
        metadata.get(
            "terminal_quiescence"
        )
        is True,
        "terminal quiescence trace metadata mismatch",
    )

    require(
        metadata.get(
            "advances_logical_workload"
        )
        is False,
        "terminal quiescence trace advanced logical workload",
    )

    payload: dict[
        str,
        Any,
    ] = {
        "domain_index": (
            metadata[
                "domain_index"
            ]
        ),
        "logical_iteration": (
            metadata[
                "logical_iteration_before"
            ]
        ),
        "semantic_states": (
            copy.deepcopy(
                step_payload[
                    "semantic_states"
                ]
            )
        ),
        "phase_words": (
            copy.deepcopy(
                step_payload[
                    "phase_words"
                ]
            )
        ),
        "event_packets": (
            copy.deepcopy(
                step_payload[
                    "event_packets"
                ]
            )
        ),
        "architecture_metadata": (
            metadata
        ),
        "adapter_step_sha256": (
            step_payload[
                "adapter_step_sha256"
            ]
        ),
        "thermal_update": (
            compact_thermal_update(
                thermal_update
            )
        ),
        "convergence_observation": (
            None
        ),
        "terminal_quiescence": (
            True
        ),
    }

    return package_with_sha256(
        payload,
        "trace_row_sha256",
    )


def run_semantic_oracle(
    profile: Mapping[
        str,
        Any,
    ],
    initializations: Sequence[
        Any
    ],
    *,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
) -> dict[
    str,
    Any,
]:
    thresholds = (
        ConvergenceThresholds.from_profile(
            profile
        )
    )

    tracker = (
        CaseConvergenceTracker(
            domain_size=(
                domain_size
            ),
            concurrent_domain_count=(
                concurrent_domain_count
            ),
            thresholds=(
                thresholds
            ),
        )
    )

    states = [
        build_problem_state(
            initialization
        )
        for initialization
        in initializations
    ]

    logical_updates = [
        0
        for _
        in initializations
    ]

    oracle_tick = 0

    trace_digest = (
        hashlib.sha256()
    )

    termination_reason = (
        "semantic_completion"
    )

    while not tracker.complete:
        active = (
            tracker.active_domain_indices
        )

        require(
            active,
            (
                "oracle has no active domain "
                "before completion"
            ),
        )

        limit_reached = False

        for domain_index in active:
            if (
                logical_updates[
                    domain_index
                ]
                >= (
                    thresholds
                    .maximum_logical_iterations_per_domain
                )
            ):
                limit_reached = True
                break

            gamma_targets = (
                gamma_noise_targets_q16(
                    profile,
                    initializations[
                        domain_index
                    ],
                    tick=(
                        logical_updates[
                            domain_index
                        ]
                    ),
                )
            )

            result = (
                step_problem_domain(
                    profile,
                    states[
                        domain_index
                    ],
                    gamma_targets_q16=(
                        gamma_targets
                    ),
                )
            )

            observation = {
                domain_index: {
                    "logical_iteration": (
                        logical_updates[
                            domain_index
                        ]
                    ),
                    "semantic_states": (
                        result
                        .state
                        .semantic_states
                    ),
                    "phase_words": (
                        result
                        .state
                        .phase_words
                    ),
                }
            }

            snapshots = (
                tracker.observe_tick(
                    benchmark_tick=(
                        oracle_tick
                    ),
                    domain_observations=(
                        observation
                    ),
                )
            )

            trace_row = {
                "domain_index": (
                    domain_index
                ),
                "logical_iteration": (
                    logical_updates[
                        domain_index
                    ]
                ),
                "problem_step_sha256": (
                    result.to_dict()[
                        "problem_step_sha256"
                    ]
                ),
                "convergence_observation": (
                    snapshots[
                        domain_index
                    ].to_dict()
                ),
            }

            encoded = (
                canonical_json_bytes(
                    trace_row
                )
            )

            trace_digest.update(
                len(
                    encoded
                ).to_bytes(
                    8,
                    "big",
                )
            )

            trace_digest.update(
                encoded
            )

            states[
                domain_index
            ] = result.state

            logical_updates[
                domain_index
            ] += 1

            oracle_tick += 1

            if tracker.complete:
                break

        if limit_reached:
            termination_reason = (
                "maximum_logical_iterations_"
                "per_domain_reached"
            )

            break

    convergence_summary = (
        tracker.summary()
    )

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            ORACLE_SCHEMA
        ),
        "semantic_reference_id": (
            SEMANTIC_REFERENCE_ID
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "domain_size": (
            domain_size
        ),
        "concurrent_domain_count": (
            concurrent_domain_count
        ),
        "nonlinearity_class": (
            nonlinearity_class
        ),
        "termination_reason": (
            termination_reason
        ),
        "logical_updates_by_domain": (
            logical_updates
        ),
        "oracle_ticks": (
            oracle_tick
        ),
        "semantic_complete": (
            tracker.complete
        ),
        "semantic_outputs": (
            convergence_summary[
                "semantic_outputs"
            ]
        ),
        "convergence_summary": (
            convergence_summary
        ),
        "oracle_trace_sha256": (
            trace_digest.hexdigest()
        ),
        "winner_assertions": [],
    }

    return package_with_sha256(
        payload,
        "semantic_oracle_sha256",
    )


def build_frp_invariants(
    spec: ArchitectureSpec,
    adapter_snapshots: Sequence[
        Mapping[
            str,
            Any,
        ]
    ],
) -> dict[
    str,
    Any,
] | None:
    if not spec.is_frp:
        return None

    actual_direct_events = sum(
        int(
            snapshot[
                "actual_direct_events"
            ]
        )
        for snapshot
        in adapter_snapshots
    )

    reserved_state_events = sum(
        int(
            snapshot[
                "reserved_state_events"
            ]
        )
        for snapshot
        in adapter_snapshots
    )

    queue_overflow_events = sum(
        int(
            snapshot[
                "queue_overflow_events"
            ]
        )
        for snapshot
        in adapter_snapshots
    )

    pending_route_count_final = sum(
        int(
            snapshot[
                "pending_route_count_final"
            ]
        )
        for snapshot
        in adapter_snapshots
    )

    transition_fraction_ok = all(
        snapshot[
            "transition_fraction"
        ]
        == 0.25
        for snapshot
        in adapter_snapshots
    )

    payload = {
        "actual_direct_events": (
            actual_direct_events
        ),
        "reserved_state_events": (
            reserved_state_events
        ),
        "queue_overflow_events": (
            queue_overflow_events
        ),
        "pending_route_count_final": (
            pending_route_count_final
        ),
        "transition_fraction": (
            0.25
        ),
        "mandatory_routes": [
            "-1 -> 0 -> 1",
            "1 -> 0 -> -1",
        ],
        "tick_separated_neutral_route": (
            True
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "actual_direct_events_ok": (
            actual_direct_events
            == 0
        ),
        "reserved_state_events_ok": (
            reserved_state_events
            == 0
        ),
        "queue_overflow_events_ok": (
            queue_overflow_events
            == 0
        ),
        "pending_route_count_final_ok": (
            pending_route_count_final
            == 0
        ),
        "transition_fraction_ok": (
            transition_fraction_ok
        ),
        "all_required_invariants_ok": (
            actual_direct_events
            == 0
            and reserved_state_events
            == 0
            and queue_overflow_events
            == 0
            and pending_route_count_final
            == 0
            and transition_fraction_ok
        ),
    }

    return package_with_sha256(
        payload,
        "frp_invariant_package_sha256",
    )


def feed_partial_thermal_records_into_convergence(
    tracker: CaseConvergenceTracker,
    records: Sequence[
        Any
    ],
) -> None:
    for record in records:
        tracker.observe_tick(
            benchmark_tick=(
                record.benchmark_tick
            ),
            domain_observations={},
        )


def run_architecture_case(
    profile: Mapping[
        str,
        Any,
    ],
    thermal_context: Any,
    initializations: Sequence[
        Any
    ],
    *,
    spec: ArchitectureSpec,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
) -> dict[
    str,
    Any,
]:
    thresholds = (
        ConvergenceThresholds.from_profile(
            profile
        )
    )

    tracker = (
        CaseConvergenceTracker(
            domain_size=(
                domain_size
            ),
            concurrent_domain_count=(
                concurrent_domain_count
            ),
            thresholds=(
                thresholds
            ),
        )
    )

    governor = (
        CommonThermalCeilingGovernor(
            thermal_context
        )
    )

    adapters = [
        spec.adapter_class(
            profile,
            initialization,
        )
        for initialization
        in initializations
    ]

    committed_event_totals = (
        empty_event_counts()
    )

    attempted_event_totals = (
        empty_event_counts()
    )

    trace: list[
        dict[
            str,
            Any,
        ]
    ] = []

    aborted_logical_update: (
        dict[
            str,
            Any,
        ]
        | None
    ) = None

    termination_reason = (
        "semantic_completion"
    )

    budget_exhausted = False

    while not tracker.complete:
        active_domains = (
            tracker.active_domain_indices
        )

        require(
            active_domains,
            (
                "architecture case has no active "
                "domain before completion"
            ),
        )

        stop_case = False

        for domain_index in active_domains:
            adapter = adapters[
                domain_index
            ]

            logical_iteration = int(
                adapter.logical_updates
            )

            if (
                logical_iteration
                >= (
                    thresholds
                    .maximum_logical_iterations_per_domain
                )
            ):
                termination_reason = (
                    "maximum_logical_iterations_"
                    "per_domain_reached"
                )

                stop_case = True
                break

            gamma_targets = (
                gamma_noise_targets_q16(
                    profile,
                    initializations[
                        domain_index
                    ],
                    tick=(
                        logical_iteration
                    ),
                )
            )

            trial_adapter = (
                copy.deepcopy(
                    adapter
                )
            )

            step_result = (
                trial_adapter.step(
                    gamma_targets_q16=(
                        gamma_targets
                    ),
                )
            )

            step_payload = (
                step_result.to_dict()
            )

            require(
                step_payload[
                    "architecture_id"
                ]
                == spec.architecture_id,
                "adapter architecture_id mismatch",
            )

            require(
                step_payload[
                    "scheduler_mode"
                ]
                == EXPECTED_SCHEDULER_MODE,
                "adapter scheduler_mode mismatch",
            )

            require(
                step_payload[
                    "winner_assertions"
                ]
                == [],
                (
                    "adapter winner_assertions "
                    "must remain empty"
                ),
            )

            aggregate_event_packets(
                attempted_event_totals,
                step_result.event_packets,
            )

            thermal_preflight = (
                estimate_thermal_execution(
                    governor,
                    step_result.event_packets,
                )
            )

            remaining_ticks = (
                thermal_context
                .maximum_benchmark_ticks_per_case
                - governor.benchmark_tick
            )

            start_record_index = len(
                governor.records
            )

            start_tick = (
                governor.benchmark_tick
            )

            start_activity_ticks = (
                governor.activity_ticks
            )

            start_cooling_ticks = (
                governor.cooling_ticks
            )

            start_energy = (
                governor.total_normalized_energy
            )

            if (
                thermal_preflight[
                    "required_ticks"
                ]
                > remaining_ticks
            ):
                try:
                    governor.execute_logical_update(
                        logical_update_id=(
                            step_payload[
                                "logical_update_metadata"
                            ][
                                "logical_update_id"
                            ]
                        ),
                        event_packets=(
                            step_result.event_packets
                        ),
                    )

                except ThermalCeilingBudgetExhausted:
                    pass

                else:
                    fail(
                        (
                            "thermal execution unexpectedly "
                            "completed after preflight predicted "
                            "benchmark-tick budget exhaustion"
                        )
                    )

                partial_records = (
                    governor.records[
                        start_record_index:
                    ]
                )

                require(
                    len(
                        partial_records
                    )
                    == remaining_ticks,
                    (
                        "partial thermal execution did not "
                        "consume the remaining tick budget"
                    ),
                )

                feed_partial_thermal_records_into_convergence(
                    tracker,
                    partial_records,
                )

                termination_reason = (
                    "maximum_benchmark_ticks_per_case_"
                    "exhausted_during_logical_update"
                )

                budget_exhausted = True
                stop_case = True

                aborted_payload = {
                    "domain_index": (
                        domain_index
                    ),
                    "logical_iteration": (
                        logical_iteration
                    ),
                    "logical_update_id": (
                        step_payload[
                            "logical_update_metadata"
                        ][
                            "logical_update_id"
                        ]
                    ),
                    "adapter_step_sha256": (
                        step_payload[
                            "adapter_step_sha256"
                        ]
                    ),
                    "event_packets": (
                        copy.deepcopy(
                            step_payload[
                                "event_packets"
                            ]
                        )
                    ),
                    "architecture_metadata": (
                        copy.deepcopy(
                            step_payload[
                                "logical_update_metadata"
                            ]
                        )
                    ),
                    "thermal_preflight": (
                        thermal_preflight
                    ),
                    "remaining_ticks_before_attempt": (
                        remaining_ticks
                    ),
                    "partial_benchmark_tick_start": (
                        start_tick
                    ),
                    "partial_benchmark_tick_end_inclusive": (
                        governor.benchmark_tick
                        - 1
                    ),
                    "partial_benchmark_ticks_consumed": (
                        governor.benchmark_tick
                        - start_tick
                    ),
                    "partial_activity_ticks_consumed": (
                        governor.activity_ticks
                        - start_activity_ticks
                    ),
                    "partial_cooling_ticks_consumed": (
                        governor.cooling_ticks
                        - start_cooling_ticks
                    ),
                    "partial_normalized_energy_consumed": (
                        math.fsum(
                            [
                                (
                                    governor
                                    .total_normalized_energy
                                ),
                                -start_energy,
                            ]
                        )
                    ),
                    "logical_update_committed": (
                        False
                    ),
                    "logical_convergence_progress": (
                        False
                    ),
                    "trial_adapter_discarded": (
                        True
                    ),
                }

                aborted_logical_update = (
                    package_with_sha256(
                        aborted_payload,
                        "aborted_logical_update_sha256",
                    )
                )

                break

            try:
                thermal_update = (
                    governor.execute_logical_update(
                        logical_update_id=(
                            step_payload[
                                "logical_update_metadata"
                            ][
                                "logical_update_id"
                            ]
                        ),
                        event_packets=(
                            step_result.event_packets
                        ),
                    )
                )

            except ThermalCeilingBudgetExhausted as exc:
                fail(
                    (
                        "thermal preflight/commit "
                        f"divergence: {exc}"
                    )
                )

            require(
                thermal_update[
                    "benchmark_ticks_consumed"
                ]
                == thermal_preflight[
                    "required_ticks"
                ],
                (
                    "thermal preflight tick count "
                    "diverged from committed execution"
                ),
            )

            require(
                thermal_update[
                    "activity_ticks_consumed"
                ]
                == thermal_preflight[
                    "activity_ticks"
                ],
                (
                    "thermal preflight activity-tick "
                    "count diverged"
                ),
            )

            require(
                thermal_update[
                    "cooling_ticks_consumed"
                ]
                == thermal_preflight[
                    "cooling_ticks"
                ],
                (
                    "thermal preflight cooling-tick "
                    "count diverged"
                ),
            )

            require(
                math.isclose(
                    thermal_update[
                        "temperature_after"
                    ],
                    thermal_preflight[
                        "temperature_after"
                    ],
                    rel_tol=0.0,
                    abs_tol=1e-12,
                ),
                (
                    "thermal preflight final "
                    "temperature diverged"
                ),
            )

            convergence_snapshot = (
                feed_thermal_update_into_convergence(
                    tracker,
                    domain_index=(
                        domain_index
                    ),
                    logical_iteration=(
                        logical_iteration
                    ),
                    semantic_states=(
                        step_result.semantic_states
                    ),
                    phase_words=(
                        step_result.phase_words
                    ),
                    thermal_update=(
                        thermal_update
                    ),
                )
            )

            adapters[
                domain_index
            ] = trial_adapter

            aggregate_event_packets(
                committed_event_totals,
                step_result.event_packets,
            )

            trace.append(
                build_trace_row(
                    step_payload=(
                        step_payload
                    ),
                    thermal_update=(
                        thermal_update
                    ),
                    convergence_snapshot=(
                        convergence_snapshot
                    ),
                )
            )

            if tracker.complete:
                break

        if stop_case:
            break

    if spec.is_frp:
        for domain_index in range(
            len(
                adapters
            )
        ):
            while True:
                current_snapshot = (
                    adapters[
                        domain_index
                    ].snapshot()
                )

                if (
                    current_snapshot[
                        "pending_route_count_final"
                    ]
                    == 0
                ):
                    break

                require(
                    not budget_exhausted,
                    "FRP terminal pending route remains after "
                    "benchmark-tick budget exhaustion",
                )

                trial_adapter = copy.deepcopy(
                    adapters[
                        domain_index
                    ]
                )

                quiescence_result = (
                    trial_adapter
                    .quiescence_step()
                )

                quiescence_payload = (
                    quiescence_result
                    .to_dict()
                )

                require(
                    quiescence_payload[
                        "architecture_id"
                    ]
                    == spec.architecture_id,
                    "terminal quiescence architecture_id mismatch",
                )

                require(
                    quiescence_payload[
                        "scheduler_mode"
                    ]
                    == EXPECTED_SCHEDULER_MODE,
                    "terminal quiescence scheduler_mode mismatch",
                )

                require(
                    quiescence_payload[
                        "winner_assertions"
                    ]
                    == [],
                    "terminal quiescence winner_assertions "
                    "must remain empty",
                )

                aggregate_event_packets(
                    attempted_event_totals,
                    quiescence_result
                    .event_packets,
                )

                quiescence_preflight = (
                    estimate_thermal_execution(
                        governor,
                        quiescence_result
                        .event_packets,
                    )
                )

                remaining_ticks = (
                    thermal_context
                    .maximum_benchmark_ticks_per_case
                    - governor.benchmark_tick
                )

                require(
                    quiescence_preflight[
                        "required_ticks"
                    ]
                    <= remaining_ticks,
                    "FRP terminal quiescence does not fit "
                    "within the remaining benchmark-tick budget",
                )

                start_record_index = len(
                    governor.records
                )

                quiescence_thermal_update = (
                    execute_terminal_quiescence_thermal_update(
                        governor,
                        terminal_update_id=(
                            quiescence_payload[
                                "logical_update_metadata"
                            ][
                                "logical_update_id"
                            ]
                        ),
                        event_packets=(
                            quiescence_result
                            .event_packets
                        ),
                    )
                )

                terminal_records = (
                    governor.records[
                        start_record_index:
                    ]
                )

                if not tracker.complete:
                    feed_partial_thermal_records_into_convergence(
                        tracker,
                        terminal_records,
                    )

                adapters[
                    domain_index
                ] = trial_adapter

                aggregate_event_packets(
                    committed_event_totals,
                    quiescence_result
                    .event_packets,
                )

                trace.append(
                    build_terminal_quiescence_trace_row(
                        step_payload=(
                            quiescence_payload
                        ),
                        thermal_update=(
                            quiescence_thermal_update
                        ),
                    )
                )

    convergence_summary = (
        tracker.summary()
    )

    thermal_summary = (
        governor.summary(
            semantic_complete=(
                tracker.complete
            ),
            benchmark_tick_budget_exhausted=(
                budget_exhausted
            ),
        )
    )

    adapter_snapshots = [
        adapter.snapshot()
        for adapter
        in adapters
    ]

    frp_invariants = (
        build_frp_invariants(
            spec,
            adapter_snapshots,
        )
    )

    if budget_exhausted:
        require(
            governor.benchmark_tick
            == (
                thermal_context
                .maximum_benchmark_ticks_per_case
            ),
            (
                "budget-exhausted case did not end "
                "at the maximum benchmark tick"
            ),
        )

        require(
            thermal_summary[
                "thermal_ceiling_status"
            ]
            == "ceiling_violation",
            (
                "budget-exhausted case must record "
                "ceiling_violation"
            ),
        )

    primary_metrics = {
        "time_to_first_solution_ticks": (
            convergence_summary[
                "time_to_first_solution_ticks"
            ]
        ),
        "time_to_all_solutions_ticks": (
            convergence_summary[
                "time_to_all_solutions_ticks"
            ]
        ),
        "solutions_completed": (
            convergence_summary[
                "solutions_completed"
            ]
        ),
        "steady_state_throughput": (
            convergence_summary[
                "steady_state_throughput"
            ]
        ),
        "throughput_retention_ratio": (
            None
        ),
        "latency_growth_ratio": (
            None
        ),
    }

    secondary_metrics = {
        "heat_peak": (
            thermal_summary[
                "peak_temperature_proxy"
            ]
        ),
        "thermal_ceiling_status": (
            thermal_summary[
                "thermal_ceiling_status"
            ]
        ),
        "thermal_throttle_ticks": (
            thermal_summary[
                "thermal_throttle_ticks"
            ]
        ),
        "total_normalized_energy": (
            thermal_summary[
                "total_normalized_energy"
            ]
        ),
        "semantic_completion_ratio": (
            convergence_summary[
                "semantic_completion_ratio"
            ]
        ),
        "semantic_output_match": (
            None
        ),
    }

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            ARCHITECTURE_CASE_SCHEMA
        ),
        "architecture_id": (
            spec.architecture_id
        ),
        "architecture_name": (
            spec.architecture_name
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "domain_size": (
            domain_size
        ),
        "concurrent_domain_count": (
            concurrent_domain_count
        ),
        "nonlinearity_class": (
            nonlinearity_class
        ),
        "termination_reason": (
            termination_reason
        ),
        "benchmark_tick_budget_exhausted": (
            budget_exhausted
        ),
        "primary_metrics": (
            primary_metrics
        ),
        "secondary_metrics": (
            secondary_metrics
        ),
        "convergence_summary": (
            convergence_summary
        ),
        "thermal_summary": (
            thermal_summary
        ),
        "semantic_comparison": (
            None
        ),
        "ranking_eligibility": (
            None
        ),
        "raw_event_counters": (
            dict(
                committed_event_totals
            )
        ),
        "raw_event_counters_committed": (
            dict(
                committed_event_totals
            )
        ),
        "raw_event_counters_attempted": (
            dict(
                attempted_event_totals
            )
        ),
        "raw_architecture_trace": (
            trace
        ),
        "raw_architecture_trace_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    trace
                )
            )
        ),
        "aborted_logical_update": (
            aborted_logical_update
        ),
        "adapter_snapshots": (
            adapter_snapshots
        ),
        "frp_invariants": (
            frp_invariants
        ),
        "winner_assertions": [],
    }

    return package_with_sha256(
        payload,
        "architecture_case_result_sha256",
    )


def incomplete_semantic_comparison(
    *,
    oracle_complete: bool,
    candidate_complete: bool,
    domain_count: int,
) -> dict[
    str,
    Any,
]:
    payload = {
        "status": (
            "not_comparable_incomplete"
        ),
        "semantic_reference_id": (
            SEMANTIC_REFERENCE_ID
        ),
        "oracle_complete": (
            oracle_complete
        ),
        "candidate_complete": (
            candidate_complete
        ),
        "domain_count": (
            domain_count
        ),
        "matched_domains": (
            0
        ),
        "semantic_output_match": (
            0.0
        ),
        "exact_match": (
            False
        ),
        "reason": (
            "semantic comparison requires complete "
            "oracle and candidate outputs"
        ),
    }

    return package_with_sha256(
        payload,
        "semantic_comparison_sha256",
    )


def attach_semantic_comparisons(
    case_payload: dict[
        str,
        Any,
    ],
) -> None:
    oracle = case_payload[
        "semantic_oracle"
    ]

    oracle_outputs = oracle[
        "semantic_outputs"
    ]

    oracle_complete = bool(
        oracle[
            "semantic_complete"
        ]
    )

    for (
        architecture_result,
        spec,
    ) in zip(
        case_payload[
            "architectures"
        ],
        ARCHITECTURE_SPECS,
    ):
        convergence = (
            architecture_result[
                "convergence_summary"
            ]
        )

        candidate_complete = (
            convergence[
                "semantic_completion_ratio"
            ]
            == 1.0
            and convergence[
                "semantic_outputs"
            ]
            is not None
        )

        if (
            oracle_complete
            and candidate_complete
        ):
            base_comparison = (
                compare_semantic_outputs(
                    oracle_outputs,
                    convergence[
                        "semantic_outputs"
                    ],
                )
            )

            base_comparison.pop(
                "semantic_comparison_sha256",
                None,
            )

            comparison = {
                "status": (
                    "compared"
                ),
                "semantic_reference_id": (
                    SEMANTIC_REFERENCE_ID
                ),
                **base_comparison,
            }

            comparison[
                "semantic_comparison_sha256"
            ] = sha256_hex(
                canonical_json_bytes(
                    comparison
                )
            )

        else:
            comparison = (
                incomplete_semantic_comparison(
                    oracle_complete=(
                        oracle_complete
                    ),
                    candidate_complete=(
                        candidate_complete
                    ),
                    domain_count=(
                        case_payload[
                            "concurrent_domain_count"
                        ]
                    ),
                )
            )

        semantic_output_match = float(
            comparison[
                "semantic_output_match"
            ]
        )

        architecture_result[
            "semantic_comparison"
        ] = comparison

        architecture_result[
            "secondary_metrics"
        ][
            "semantic_output_match"
        ] = semantic_output_match

        frp_invariants_ok = None

        if spec.is_frp:
            frp_invariants_ok = (
                architecture_result[
                    "frp_invariants"
                ][
                    "all_required_invariants_ok"
                ]
            )

        architecture_result[
            "ranking_eligibility"
        ] = ranking_eligibility(
            case_payload[
                "workload_profile"
            ],
            semantic_completion_ratio=(
                architecture_result[
                    "secondary_metrics"
                ][
                    "semantic_completion_ratio"
                ]
            ),
            semantic_output_match=(
                semantic_output_match
            ),
            thermal_ceiling_status=(
                architecture_result[
                    "secondary_metrics"
                ][
                    "thermal_ceiling_status"
                ]
            ),
            frp_invariants_ok=(
                frp_invariants_ok
            ),
            is_frp=(
                spec.is_frp
            ),
        )

        digest_field = (
            "architecture_case_result_sha256"
        )

        architecture_result.pop(
            digest_field,
            None,
        )

        architecture_result[
            digest_field
        ] = sha256_hex(
            canonical_json_bytes(
                architecture_result
            )
        )


def derive_scaling_metrics(
    cases: Sequence[
        dict[
            str,
            Any,
        ]
    ],
) -> None:
    index: dict[
        tuple[
            str,
            int,
            int,
            str,
        ],
        dict[
            str,
            Any,
        ],
    ] = {}

    for case in cases:
        for result in case[
            "architectures"
        ]:
            key = (
                result[
                    "architecture_id"
                ],
                case[
                    "domain_size"
                ],
                case[
                    "concurrent_domain_count"
                ],
                case[
                    "nonlinearity_class"
                ],
            )

            require(
                key
                not in index,
                f"duplicate scaling case key: {key}",
            )

            index[
                key
            ] = result

    for case in cases:
        concurrency = case[
            "concurrent_domain_count"
        ]

        for result in case[
            "architectures"
        ]:
            baseline_key = (
                result[
                    "architecture_id"
                ],
                case[
                    "domain_size"
                ],
                1,
                case[
                    "nonlinearity_class"
                ],
            )

            baseline = index[
                baseline_key
            ]

            current_latency = (
                result[
                    "primary_metrics"
                ][
                    "time_to_all_solutions_ticks"
                ]
            )

            baseline_latency = (
                baseline[
                    "primary_metrics"
                ][
                    "time_to_all_solutions_ticks"
                ]
            )

            current_throughput = (
                result[
                    "primary_metrics"
                ][
                    "steady_state_throughput"
                ]
            )

            baseline_throughput = (
                baseline[
                    "primary_metrics"
                ][
                    "steady_state_throughput"
                ]
            )

            latency_growth = None

            if (
                current_latency
                is not None
                and baseline_latency
                is not None
                and baseline_latency
                > 0
            ):
                latency_growth = (
                    current_latency
                    / baseline_latency
                )

            throughput_retention = None

            if (
                current_throughput
                is not None
                and baseline_throughput
                is not None
                and baseline_throughput
                > 0.0
            ):
                throughput_retention = (
                    current_throughput
                    / (
                        baseline_throughput
                        * concurrency
                    )
                )

            result[
                "primary_metrics"
            ][
                "latency_growth_ratio"
            ] = latency_growth

            result[
                "primary_metrics"
            ][
                "throughput_retention_ratio"
            ] = throughput_retention

            digest_field = (
                "architecture_case_result_sha256"
            )

            result.pop(
                digest_field,
                None,
            )

            result[
                digest_field
            ] = sha256_hex(
                canonical_json_bytes(
                    result
                )
            )


def build_case_payload(
    profile: Mapping[
        str,
        Any,
    ],
    thermal_context: Any,
    *,
    case_index: int,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
) -> dict[
    str,
    Any,
]:
    initializations = (
        build_case_initializations(
            profile,
            domain_size=(
                domain_size
            ),
            concurrent_domain_count=(
                concurrent_domain_count
            ),
            nonlinearity_class=(
                nonlinearity_class
            ),
        )
    )

    require(
        len(
            initializations
        )
        == concurrent_domain_count,
        "case initialization count mismatch",
    )

    semantic_oracle = (
        run_semantic_oracle(
            profile,
            initializations,
            domain_size=(
                domain_size
            ),
            concurrent_domain_count=(
                concurrent_domain_count
            ),
            nonlinearity_class=(
                nonlinearity_class
            ),
        )
    )

    architecture_results = [
        run_architecture_case(
            profile,
            thermal_context,
            initializations,
            spec=(
                spec
            ),
            domain_size=(
                domain_size
            ),
            concurrent_domain_count=(
                concurrent_domain_count
            ),
            nonlinearity_class=(
                nonlinearity_class
            ),
        )
        for spec
        in ARCHITECTURE_SPECS
    ]

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            CASE_SCHEMA
        ),
        "case_index": (
            case_index
        ),
        "case_id": (
            f"d{domain_size:03d}-"
            f"c{concurrent_domain_count:02d}-"
            f"{nonlinearity_class}"
        ),
        "domain_size": (
            domain_size
        ),
        "concurrent_domain_count": (
            concurrent_domain_count
        ),
        "nonlinearity_class": (
            nonlinearity_class
        ),
        "domain_initialization_sha256": [
            initialization.sha256()
            for initialization
            in initializations
        ],
        "semantic_oracle": (
            semantic_oracle
        ),
        "architectures": (
            architecture_results
        ),
        "winner_assertions": [],
    }

    payload[
        "workload_profile"
    ] = profile

    attach_semantic_comparisons(
        payload
    )

    payload.pop(
        "workload_profile"
    )

    return package_with_sha256(
        payload,
        "case_result_sha256",
    )


def build_metric_definitions(
) -> dict[
    str,
    Any,
]:
    return {
        "primary_metric_unit": (
            "benchmark_ticks"
        ),
        "time_to_first_solution_ticks": (
            "zero-based completion benchmark tick "
            "of the first completed domain plus one"
        ),
        "time_to_all_solutions_ticks": (
            "zero-based completion benchmark tick "
            "of the final completed domain plus one"
        ),
        "steady_state_throughput": (
            "concurrent_domain_count / "
            "time_to_all_solutions_ticks"
        ),
        "latency_growth_ratio": (
            "time_to_all_solutions_ticks(concurrency) / "
            "time_to_all_solutions_ticks(concurrency=1) "
            "for the same architecture, domain size, "
            "and nonlinearity class"
        ),
        "throughput_retention_ratio": (
            "steady_state_throughput(concurrency) / "
            "(steady_state_throughput(concurrency=1) * "
            "concurrent_domain_count) for the same architecture, "
            "domain size, and nonlinearity class"
        ),
        "throughput_retention_ratio_interpretation": (
            "1.0 is ideal linear throughput retention relative "
            "to the architecture's own single-domain baseline; "
            "values below 1.0 indicate degradation"
        ),
        "heat_peak": (
            "maximum common normalized temperature proxy"
        ),
        "semantic_output_match": (
            "exact domain-vector match against "
            "shared_problem_oracle_v1"
        ),
        "ranking_eligibility": (
            "requires semantic completion ratio 1.0, "
            "semantic output match 1.0, no thermal ceiling "
            "violation, and FRP invariants for the FRP path"
        ),
        "host_wall_clock_used_for_ranking": (
            False
        ),
        "winner_assertions": [],
    }


def build_result_package(
    profile: Mapping[
        str,
        Any,
    ],
    profile_path: Path,
) -> dict[
    str,
    Any,
]:
    validation = (
        validate_profile(
            profile,
            repository_root=(
                REPOSITORY_ROOT
            ),
        )
    )

    validate_runner_contract(
        profile
    )

    thermal_context = (
        build_thermal_ceiling_context(
            profile,
            REPOSITORY_ROOT,
        )
    )

    initialization_manifest = (
        build_initialization_manifest(
            profile
        )
    )

    problem_contract = (
        build_problem_contract_summary(
            profile
        )
    )

    convergence_contract = (
        build_convergence_contract_summary(
            profile
        )
    )

    architecture_contracts = (
        build_architecture_contracts(
            profile
        )
    )

    source_bindings = (
        build_source_bindings(
            profile_path
        )
    )

    cases: list[
        dict[
            str,
            Any,
        ]
    ] = []

    case_index = 0

    for domain_size in profile[
        "domain_size_order"
    ]:
        for concurrent_domain_count in profile[
            "concurrent_domain_count_order"
        ]:
            for nonlinearity_class in profile[
                "nonlinearity_class_order"
            ]:
                cases.append(
                    build_case_payload(
                        profile,
                        thermal_context,
                        case_index=(
                            case_index
                        ),
                        domain_size=(
                            domain_size
                        ),
                        concurrent_domain_count=(
                            concurrent_domain_count
                        ),
                        nonlinearity_class=(
                            nonlinearity_class
                        ),
                    )
                )

                case_index += 1

    require(
        len(
            cases
        )
        == profile[
            "case_count"
        ]
        == 36,
        "canonical case count mismatch",
    )

    derive_scaling_metrics(
        cases
    )

    for case in cases:
        digest_field = (
            "case_result_sha256"
        )

        case.pop(
            digest_field,
            None,
        )

        case[
            digest_field
        ] = sha256_hex(
            canonical_json_bytes(
                case
            )
        )

    architecture_summary = []

    for spec in ARCHITECTURE_SPECS:
        architecture_results = [
            result
            for case
            in cases
            for result
            in case[
                "architectures"
            ]
            if result[
                "architecture_id"
            ]
            == spec.architecture_id
        ]

        architecture_summary.append(
            {
                "architecture_id": (
                    spec.architecture_id
                ),
                "architecture_name": (
                    spec.architecture_name
                ),
                "case_count": (
                    len(
                        architecture_results
                    )
                ),
                "semantically_complete_case_count": (
                    sum(
                        1
                        for result
                        in architecture_results
                        if (
                            result[
                                "secondary_metrics"
                            ][
                                "semantic_completion_ratio"
                            ]
                            == 1.0
                        )
                    )
                ),
                "semantic_match_case_count": (
                    sum(
                        1
                        for result
                        in architecture_results
                        if (
                            result[
                                "secondary_metrics"
                            ][
                                "semantic_output_match"
                            ]
                            == 1.0
                        )
                    )
                ),
                "ranking_eligible_case_count": (
                    sum(
                        1
                        for result
                        in architecture_results
                        if (
                            result[
                                "ranking_eligibility"
                            ][
                                "eligible"
                            ]
                            is True
                        )
                    )
                ),
                "thermal_ceiling_violation_case_count": (
                    sum(
                        1
                        for result
                        in architecture_results
                        if (
                            result[
                                "secondary_metrics"
                            ][
                                "thermal_ceiling_status"
                            ]
                            == "ceiling_violation"
                        )
                    )
                ),
            }
        )

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            RESULT_SCHEMA
        ),
        "benchmark_id": (
            BENCHMARK_ID
        ),
        "suite_name": (
            profile[
                "suite_name"
            ]
        ),
        "workload_profile_name": (
            profile[
                "profile_name"
            ]
        ),
        "workload_profile_sha256": (
            profile[
                "workload_profile_sha256"
            ]
        ),
        "seed": (
            profile[
                "seed"
            ]
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "scheduler_7_1_enabled": (
            False
        ),
        "scheduler_1_7_enabled": (
            False
        ),
        "semantic_reference_id": (
            SEMANTIC_REFERENCE_ID
        ),
        "architecture_order": list(
            EXPECTED_ARCHITECTURE_ORDER
        ),
        "case_count": (
            len(
                cases
            )
        ),
        "architecture_case_count": (
            len(
                cases
            )
            * len(
                ARCHITECTURE_SPECS
            )
        ),
        "domain_size_order": (
            copy.deepcopy(
                profile[
                    "domain_size_order"
                ]
            )
        ),
        "concurrent_domain_count_order": (
            copy.deepcopy(
                profile[
                    "concurrent_domain_count_order"
                ]
            )
        ),
        "nonlinearity_class_order": (
            copy.deepcopy(
                profile[
                    "nonlinearity_class_order"
                ]
            )
        ),
        "workload_validation": (
            validation
        ),
        "source_bindings": (
            source_bindings
        ),
        "initialization_manifest": (
            initialization_manifest
        ),
        "problem_contract": (
            problem_contract
        ),
        "convergence_contract": (
            convergence_contract
        ),
        "thermal_ceiling_contract": (
            thermal_context.to_dict()
        ),
        "architecture_contracts": (
            architecture_contracts
        ),
        "metric_definitions": (
            build_metric_definitions()
        ),
        "cases": (
            cases
        ),
        "architecture_summary": (
            architecture_summary
        ),
        "ranking": (
            None
        ),
        "winner_assertions": [],
    }

    return package_with_sha256(
        payload,
        "package_sha256",
    )


def integration_probe(
    profile: Mapping[
        str,
        Any,
    ],
    thermal_context: Any,
) -> dict[
    str,
    Any,
]:
    initializations = (
        build_case_initializations(
            profile,
            domain_size=8,
            concurrent_domain_count=1,
            nonlinearity_class="low",
        )
    )

    initialization = (
        initializations[
            0
        ]
    )

    gamma_targets = (
        gamma_noise_targets_q16(
            profile,
            initialization,
            tick=0,
        )
    )

    rows = []

    for spec in ARCHITECTURE_SPECS:
        adapter = spec.adapter_class(
            profile,
            initialization,
        )

        result = adapter.step(
            gamma_targets_q16=(
                gamma_targets
            )
        )

        payload = (
            result.to_dict()
        )

        governor = (
            CommonThermalCeilingGovernor(
                thermal_context
            )
        )

        preflight = (
            estimate_thermal_execution(
                governor,
                result.event_packets,
            )
        )

        require(
            preflight[
                "required_ticks"
            ]
            <= (
                thermal_context
                .maximum_benchmark_ticks_per_case
            ),
            (
                "self-test first logical update "
                "does not fit for "
                f"{spec.architecture_id}"
            ),
        )

        thermal_update = (
            governor.execute_logical_update(
                logical_update_id=(
                    payload[
                        "logical_update_metadata"
                    ][
                        "logical_update_id"
                    ]
                ),
                event_packets=(
                    result.event_packets
                ),
            )
        )

        require(
            thermal_update[
                "benchmark_ticks_consumed"
            ]
            == preflight[
                "required_ticks"
            ],
            (
                "self-test thermal "
                "preflight mismatch"
            ),
        )

        snapshot = (
            adapter.snapshot()
        )

        terminal_quiescence = []

        if spec.is_frp:
            while (
                snapshot[
                    "pending_route_count_final"
                ]
                > 0
            ):
                quiescence_result = (
                    adapter
                    .quiescence_step()
                )

                quiescence_payload = (
                    quiescence_result
                    .to_dict()
                )

                quiescence_preflight = (
                    estimate_thermal_execution(
                        governor,
                        quiescence_result
                        .event_packets,
                    )
                )

                require(
                    quiescence_preflight[
                        "required_ticks"
                    ]
                    <= (
                        thermal_context
                        .maximum_benchmark_ticks_per_case
                        - governor.benchmark_tick
                    ),
                    "self-test FRP terminal quiescence "
                    "does not fit",
                )

                quiescence_thermal_update = (
                    execute_terminal_quiescence_thermal_update(
                        governor,
                        terminal_update_id=(
                            quiescence_payload[
                                "logical_update_metadata"
                            ][
                                "logical_update_id"
                            ]
                        ),
                        event_packets=(
                            quiescence_result
                            .event_packets
                        ),
                    )
                )

                terminal_quiescence.append(
                    {
                        "adapter_step_sha256": (
                            quiescence_payload[
                                "adapter_step_sha256"
                            ]
                        ),
                        "thermal_preflight": (
                            quiescence_preflight
                        ),
                        "terminal_quiescence_thermal_sha256": (
                            quiescence_thermal_update[
                                "terminal_quiescence_thermal_sha256"
                            ]
                        ),
                    }
                )

                snapshot = (
                    adapter.snapshot()
                )

            require(
                snapshot[
                    "pending_route_count_final"
                ]
                == 0,
                "self-test FRP terminal quiescence "
                "did not drain pending routes",
            )

            require(
                snapshot[
                    "actual_direct_events"
                ]
                == 0,
                (
                    "self-test FRP direct-transition "
                    "invariant failed"
                ),
            )

            require(
                snapshot[
                    "reserved_state_events"
                ]
                == 0,
                (
                    "self-test FRP reserved-state "
                    "invariant failed"
                ),
            )

            require(
                snapshot[
                    "queue_overflow_events"
                ]
                == 0,
                (
                    "self-test FRP queue-overflow "
                    "invariant failed"
                ),
            )

        rows.append(
            {
                "architecture_id": (
                    spec.architecture_id
                ),
                "adapter_step_sha256": (
                    payload[
                        "adapter_step_sha256"
                    ]
                ),
                "event_packets": (
                    copy.deepcopy(
                        payload[
                            "event_packets"
                        ]
                    )
                ),
                "thermal_preflight": (
                    preflight
                ),
                "logical_update_thermal_sha256": (
                    thermal_update[
                        "logical_update_thermal_sha256"
                    ]
                ),
                "adapter_snapshot_sha256": (
                    snapshot[
                        "adapter_snapshot_sha256"
                    ]
                ),
                "terminal_quiescence": (
                    terminal_quiescence
                ),
            }
        )

    payload = {
        "schema": (
            SELF_TEST_SCHEMA
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "domain_size": (
            8
        ),
        "concurrent_domain_count": (
            1
        ),
        "nonlinearity_class": (
            "low"
        ),
        "architectures": (
            rows
        ),
        "winner_assertions": [],
    }

    return package_with_sha256(
        payload,
        "integration_probe_sha256",
    )


def run_self_test(
    profile: Mapping[
        str,
        Any,
    ],
    profile_path: Path,
) -> dict[
    str,
    Any,
]:
    validation = (
        validate_profile(
            profile,
            repository_root=(
                REPOSITORY_ROOT
            ),
        )
    )

    validate_runner_contract(
        profile
    )

    build_source_bindings(
        profile_path
    )

    thermal_context = (
        build_thermal_ceiling_context(
            profile,
            REPOSITORY_ROOT,
        )
    )

    first = integration_probe(
        profile,
        thermal_context,
    )

    second = integration_probe(
        profile,
        thermal_context,
    )

    require(
        first
        == second,
        (
            "repeated runner integration "
            "probes differ"
        ),
    )

    payload = {
        "schema": (
            SELF_TEST_SCHEMA
        ),
        "status": (
            "PASS"
        ),
        "workload_profile_sha256": (
            validation[
                "workload_profile_sha256"
            ]
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "architecture_order": list(
            EXPECTED_ARCHITECTURE_ORDER
        ),
        "integration_probe_sha256": (
            first[
                "integration_probe_sha256"
            ]
        ),
        "repeated_probe_byte_identical": (
            True
        ),
        "winner_assertions": [],
    }

    return package_with_sha256(
        payload,
        "runner_self_test_sha256",
    )


def write_result(
    path: Path,
    payload: Mapping[
        str,
        Any,
    ],
) -> None:
    target = (
        path
        .expanduser()
        .resolve()
    )

    target.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    try:
        target.write_text(
            pretty_json_text(
                payload
            ),
            encoding="utf-8",
        )

    except OSError as exc:
        fail(
            f"unable to write result file {target}: {exc}"
        )


def build_parser(
) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Run the canonical FRP nonlinear "
            "multitask convergence benchmark."
        )
    )

    parser.add_argument(
        "--profile",
        default=str(
            REPOSITORY_ROOT
            / DEFAULT_PROFILE_RELATIVE
        ),
        help=(
            "Path to "
            "nonlinear_multitask_workload_v1.json"
        ),
    )

    parser.add_argument(
        "--output",
        default=str(
            REPOSITORY_ROOT
            / DEFAULT_RESULT_RELATIVE
        ),
        help=(
            "Path for the canonical "
            "machine-readable result JSON"
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run a bounded deterministic "
            "four-adapter integration probe."
        ),
    )

    parser.add_argument(
        "--json",
        action="store_true",
        help=(
            "Print self-test or completion "
            "summary as JSON."
        ),
    )

    return parser


def main(
    argv: Sequence[
        str
    ] | None = None,
) -> int:
    parser = build_parser()

    args = parser.parse_args(
        argv
    )

    profile_path = (
        Path(
            args.profile
        )
        .expanduser()
        .resolve()
    )

    try:
        profile = (
            load_json_object(
                profile_path,
                (
                    "nonlinear multitask "
                    "workload profile"
                ),
            )
        )

        if args.self_test:
            result = (
                run_self_test(
                    profile,
                    profile_path,
                )
            )

            if args.json:
                print(
                    pretty_json_text(
                        result
                    ),
                    end="",
                )

            else:
                print(
                    "nonlinear multitask "
                    "runner self-test: PASS"
                )

                print(
                    "scheduler_mode="
                    f"{result['scheduler_mode']}"
                )

                print(
                    "integration_probe_sha256="
                    f"{result['integration_probe_sha256']}"
                )

            return 0

        result = (
            build_result_package(
                profile,
                profile_path,
            )
        )

        output_path = (
            Path(
                args.output
            )
            .expanduser()
            .resolve()
        )

        write_result(
            output_path,
            result,
        )

        summary = {
            "status": (
                "GENERATED"
            ),
            "benchmark_id": (
                result[
                    "benchmark_id"
                ]
            ),
            "case_count": (
                result[
                    "case_count"
                ]
            ),
            "architecture_case_count": (
                result[
                    "architecture_case_count"
                ]
            ),
            "scheduler_mode": (
                result[
                    "scheduler_mode"
                ]
            ),
            "package_sha256": (
                result[
                    "package_sha256"
                ]
            ),
            "output": (
                str(
                    output_path
                )
            ),
            "winner_assertions": [],
        }

        if args.json:
            print(
                pretty_json_text(
                    summary
                ),
                end="",
            )

        else:
            print(
                "nonlinear multitask "
                "canonical result: GENERATED"
            )

            print(
                "case_count="
                f"{summary['case_count']}"
            )

            print(
                "architecture_case_count="
                f"{summary['architecture_case_count']}"
            )

            print(
                "scheduler_mode="
                f"{summary['scheduler_mode']}"
            )

            print(
                "package_sha256="
                f"{summary['package_sha256']}"
            )

            print(
                "output="
                f"{summary['output']}"
            )

        return 0

    except Exception as exc:
        if args.json:
            print(
                pretty_json_text(
                    {
                        "status": (
                            "FAIL"
                        ),
                        "error": (
                            str(
                                exc
                            )
                        ),
                    }
                ),
                end="",
            )

        else:
            print(
                "nonlinear multitask runner: FAIL"
            )

            print(
                f"error={exc}"
            )

        return 1


if __name__ == "__main__":
    sys.exit(
        main()
    )

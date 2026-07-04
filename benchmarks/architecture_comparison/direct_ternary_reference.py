#!/usr/bin/env python3
"""Direct ternary baseline for the FRP architecture comparison suite."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any, Mapping, Sequence

from common_cost_model import (
    CostModelError,
    EVENT_FIELDS,
    empty_event_counts,
    validate_event_counts,
)
from common_workload import (
    ISSUE_POLICY_TRANSACTION_SERIAL,
    NEGATIVE_TARGET,
    POSITIVE_TARGET,
    WorkloadError,
    WorkloadProfile,
    build_workload_package,
    validate_workload_package,
)

ARCHITECTURE_RESULT_SCHEMA = "frp.benchmark.architecture_reference_result.v1"
ARCHITECTURE_SELF_TEST_SCHEMA = (
    "frp.benchmark.direct_ternary_reference.self_test.v1"
)
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
ARCHITECTURE_ID = "direct_ternary_reference"
ARCHITECTURE_NAME = "Direct Ternary Reference"

TERNARY_NEGATIVE = -1
TERNARY_NEUTRAL = 0
TERNARY_POSITIVE = 1

TERNARY_ENCODING = {
    TERNARY_NEGATIVE: 0b11,
    TERNARY_NEUTRAL: 0b00,
    TERNARY_POSITIVE: 0b01,
}

SEMANTIC_TO_TERNARY_STATE = {
    NEGATIVE_TARGET: TERNARY_NEGATIVE,
    POSITIVE_TARGET: TERNARY_POSITIVE,
}

STATE_BITS_PER_CELL = 2


class DirectTernaryError(ValueError):
    """Raised when the direct ternary reference receives invalid input."""


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


def _percentile_nearest_rank(
    values: Sequence[int],
    percentile: float,
) -> float:
    if not values:
        return 0.0

    if not 0.0 < percentile <= 1.0:
        raise DirectTernaryError(
            "percentile must satisfy 0 < percentile <= 1"
        )

    ordered = sorted(values)
    rank = max(1, math.ceil(percentile * len(ordered)))
    return float(ordered[rank - 1])


def _load_workload_package(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(
            path.read_text(encoding="utf-8")
        )
    except OSError as exc:
        raise DirectTernaryError(
            f"unable to read workload package: {path}"
        ) from exc
    except json.JSONDecodeError as exc:
        raise DirectTernaryError(
            f"invalid workload package JSON: {path}"
        ) from exc

    if not isinstance(value, dict):
        raise DirectTernaryError(
            "workload package JSON must contain an object"
        )

    validate_workload_package(value)
    return value


def _write_json(
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


def _encoded_bit_toggle_count(
    state_before: int,
    state_after: int,
) -> int:
    try:
        before_word = TERNARY_ENCODING[state_before]
        after_word = TERNARY_ENCODING[state_after]
    except KeyError as exc:
        raise DirectTernaryError(
            "state is outside the direct ternary domain"
        ) from exc

    return (before_word ^ after_word).bit_count()


def _is_direct_opposite_change(
    state_before: int,
    state_after: int,
) -> bool:
    return (
        state_before in (
            TERNARY_NEGATIVE,
            TERNARY_POSITIVE,
        )
        and state_after == -state_before
    )


class DirectTernaryReference:
    """Deterministic direct ternary baseline with write-enable clock gating."""

    def __init__(self, num_cells: int) -> None:
        if isinstance(num_cells, bool) or not isinstance(num_cells, int):
            raise DirectTernaryError(
                "num_cells must be an integer"
            )

        if num_cells <= 0:
            raise DirectTernaryError(
                "num_cells must be greater than zero"
            )

        self.num_cells = num_cells
        self.states = [
            TERNARY_NEUTRAL
            for _ in range(num_cells)
        ]

        self.semantic_commands_issued = 0
        self.semantic_commands_completed = 0
        self.semantic_commands_matched = 0

        self.processor_cycles = 0
        self.active_clocked_cycles = 0
        self.gated_cycles = 0

        self.logical_state_changes = 0
        self.encoded_bit_toggles = 0
        self.direct_opposite_polarity_changes = 0
        self.neutral_state_exits = 0

        self.cost_event_totals = empty_event_counts()

        self.cycle_trace: list[dict[str, Any]] = []
        self.command_trace: list[dict[str, Any]] = []
        self.command_latencies: list[int] = []

    def _target_state(
        self,
        semantic_target: str,
    ) -> int:
        try:
            return SEMANTIC_TO_TERNARY_STATE[
                semantic_target
            ]
        except KeyError as exc:
            raise DirectTernaryError(
                "unsupported semantic target: "
                f"{semantic_target}"
            ) from exc

    def _validate_cell_id(
        self,
        cell_id: int,
    ) -> None:
        if (
            isinstance(cell_id, bool)
            or not isinstance(cell_id, int)
        ):
            raise DirectTernaryError(
                "cell_id must be an integer"
            )

        if not 0 <= cell_id < self.num_cells:
            raise DirectTernaryError(
                "cell_id is outside the configured cell domain"
            )

    def _command_cycle_events(
        self,
        *,
        state_clock_active: bool,
    ) -> dict[str, int]:
        events = empty_event_counts()

        if state_clock_active:
            events["clocked_state_bits"] = STATE_BITS_PER_CELL

        events["control_events"] = 1

        return events

    def _cooldown_cycle_events(
        self,
    ) -> dict[str, int]:
        events = empty_event_counts()
        events["control_events"] = 1
        return events

    def _record_cycle(
        self,
        *,
        phase: str,
        events: Mapping[str, Any],
        state_clock_active: bool,
        command_index: int | None,
        cell_id: int | None,
        semantic_target: str | None,
        target_state: int | None,
        state_before: int | None,
        state_after: int | None,
        semantic_complete: bool | None,
        encoded_bit_toggles: int | None,
        direct_opposite_polarity_change: bool | None,
    ) -> None:
        validated_events = validate_event_counts(
            events
        )

        self.processor_cycles += 1

        if state_clock_active:
            self.active_clocked_cycles += 1
        else:
            self.gated_cycles += 1

        for event_field in EVENT_FIELDS:
            self.cost_event_totals[event_field] += (
                validated_events[event_field]
            )

        self.cycle_trace.append(
            {
                "cycle_index": (
                    self.processor_cycles - 1
                ),
                "phase": phase,
                "state_clock_active": (
                    state_clock_active
                ),
                "command_index": command_index,
                "cell_id": cell_id,
                "semantic_target": semantic_target,
                "target_state": target_state,
                "state_before": state_before,
                "state_after": state_after,
                "semantic_complete": semantic_complete,
                "encoded_bit_toggles": encoded_bit_toggles,
                "direct_opposite_polarity_change": (
                    direct_opposite_polarity_change
                ),
                "cost_events": validated_events,
            }
        )

    def execute_command(
        self,
        command: Mapping[str, Any],
        *,
        max_completion_cycles: int,
    ) -> None:
        if not isinstance(command, Mapping):
            raise DirectTernaryError(
                "command must be an object"
            )

        command_index = command.get(
            "command_index"
        )
        cell_id = command.get(
            "cell_id"
        )
        semantic_target = command.get(
            "semantic_target"
        )

        if (
            isinstance(command_index, bool)
            or not isinstance(command_index, int)
        ):
            raise DirectTernaryError(
                "command_index must be an integer"
            )

        self._validate_cell_id(
            cell_id
        )

        if (
            semantic_target
            not in SEMANTIC_TO_TERNARY_STATE
        ):
            raise DirectTernaryError(
                "invalid semantic target"
            )

        if (
            isinstance(
                max_completion_cycles,
                bool,
            )
            or not isinstance(
                max_completion_cycles,
                int,
            )
            or max_completion_cycles <= 0
        ):
            raise DirectTernaryError(
                "max_completion_cycles must be "
                "a positive integer"
            )

        self.semantic_commands_issued += 1

        target_state = self._target_state(
            semantic_target
        )

        start_cycle = self.processor_cycles
        state_before = self.states[cell_id]

        state_clock_active = (
            state_before != target_state
        )

        events = self._command_cycle_events(
            state_clock_active=state_clock_active
        )

        events["comparison_events"] = 1

        toggle_count = 0
        opposite_change = False

        if state_clock_active:
            toggle_count = _encoded_bit_toggle_count(
                state_before,
                target_state,
            )

            opposite_change = _is_direct_opposite_change(
                state_before,
                target_state,
            )

            self.states[cell_id] = target_state

            events["encoded_bit_toggles"] = toggle_count
            events["register_write_bits"] = STATE_BITS_PER_CELL

            self.logical_state_changes += 1
            self.encoded_bit_toggles += toggle_count

            if opposite_change:
                self.direct_opposite_polarity_changes += 1

            if state_before == TERNARY_NEUTRAL:
                self.neutral_state_exits += 1

        state_after = self.states[cell_id]

        semantic_complete = (
            state_after == target_state
        )

        self._record_cycle(
            phase="command",
            events=events,
            state_clock_active=state_clock_active,
            command_index=command_index,
            cell_id=cell_id,
            semantic_target=semantic_target,
            target_state=target_state,
            state_before=state_before,
            state_after=state_after,
            semantic_complete=semantic_complete,
            encoded_bit_toggles=toggle_count,
            direct_opposite_polarity_change=opposite_change,
        )

        latency_ticks = (
            self.processor_cycles
            - start_cycle
        )

        if (
            latency_ticks
            > max_completion_cycles
        ):
            raise DirectTernaryError(
                "command exceeded "
                "max_completion_cycles"
            )

        if not semantic_complete:
            raise DirectTernaryError(
                "direct ternary command did not complete"
            )

        self.semantic_commands_completed += 1
        self.semantic_commands_matched += 1

        self.command_latencies.append(
            latency_ticks
        )

        self.command_trace.append(
            {
                "command_index": command_index,
                "cell_id": cell_id,
                "semantic_target": semantic_target,
                "target_state": target_state,
                "issue_cycle": start_cycle,
                "completion_cycle": (
                    self.processor_cycles - 1
                ),
                "latency_ticks": latency_ticks,
                "state_before": state_before,
                "state_after": state_after,
                "encoded_bit_toggles": toggle_count,
                "direct_opposite_polarity_change": (
                    opposite_change
                ),
                "semantic_complete": (
                    semantic_complete
                ),
            }
        )

    def execute_cooldown(
        self,
        cycle_count: int,
    ) -> None:
        if (
            isinstance(cycle_count, bool)
            or not isinstance(cycle_count, int)
        ):
            raise DirectTernaryError(
                "cooldown cycle count must be an integer"
            )

        if cycle_count < 0:
            raise DirectTernaryError(
                "cooldown cycle count must be nonnegative"
            )

        for _ in range(cycle_count):
            events = self._cooldown_cycle_events()

            self._record_cycle(
                phase="cooldown",
                events=events,
                state_clock_active=False,
                command_index=None,
                cell_id=None,
                semantic_target=None,
                target_state=None,
                state_before=None,
                state_after=None,
                semantic_complete=None,
                encoded_bit_toggles=None,
                direct_opposite_polarity_change=None,
            )

    def build_result(
        self,
        *,
        workload_package: Mapping[str, Any],
    ) -> dict[str, Any]:
        issued = (
            self.semantic_commands_issued
        )

        completed = (
            self.semantic_commands_completed
        )

        semantic_completion_ratio = (
            completed / issued
            if issued
            else 0.0
        )

        semantic_output_match = (
            self.semantic_commands_matched
            / issued
            if issued
            else 0.0
        )

        mean_latency_ticks = (
            math.fsum(
                self.command_latencies
            )
            / len(
                self.command_latencies
            )
            if self.command_latencies
            else 0.0
        )

        p95_latency_ticks = (
            _percentile_nearest_rank(
                self.command_latencies,
                0.95,
            )
        )

        maximum_latency_ticks = (
            max(
                self.command_latencies
            )
            if self.command_latencies
            else 0
        )

        throughput_commands_per_tick = (
            completed
            / self.processor_cycles
            if self.processor_cycles
            else 0.0
        )

        active_clock_fraction = (
            self.active_clocked_cycles
            / self.processor_cycles
            if self.processor_cycles
            else 0.0
        )

        raw_event_totals = {
            "semantic_commands_issued": issued,
            "semantic_commands_completed": (
                completed
            ),
            "processor_cycles": (
                self.processor_cycles
            ),
            "active_clocked_cycles": (
                self.active_clocked_cycles
            ),
            "logical_state_changes": (
                self.logical_state_changes
            ),
            **self.cost_event_totals,
        }

        digest_payload = {
            "schema": (
                ARCHITECTURE_RESULT_SCHEMA
            ),
            "suite_name": SUITE_NAME,
            "architecture_id": (
                ARCHITECTURE_ID
            ),
            "architecture_name": (
                ARCHITECTURE_NAME
            ),
            "state_domain": [
                TERNARY_NEGATIVE,
                TERNARY_NEUTRAL,
                TERNARY_POSITIVE,
            ],
            "state_encoding": {
                "-1": "2'b11",
                "0": "2'b00",
                "+1": "2'b01",
            },
            "semantic_mapping": {
                NEGATIVE_TARGET: (
                    TERNARY_NEGATIVE
                ),
                POSITIVE_TARGET: (
                    TERNARY_POSITIVE
                ),
            },
            "execution_profile": {
                "clock_model": (
                    "state_register_clock_gated"
                ),
                "state_bits_per_cell": (
                    STATE_BITS_PER_CELL
                ),
                "initial_state": (
                    TERNARY_NEUTRAL
                ),
                "initial_state_semantics": (
                    "UNASSIGNED_NEUTRAL"
                ),
                "automatic_neutral_insertion": False,
                "opposite_polarity_transition": (
                    "direct_single_cycle"
                ),
                "cooldown_state_clock_active": False,
                "issue_policy": (
                    workload_package[
                        "workload_profile"
                    ]["issue_policy"]
                ),
            },
            "workload_sha256": (
                workload_package[
                    "workload_sha256"
                ]
            ),
            "workload_profile": (
                workload_package[
                    "workload_profile"
                ]
            ),
            "raw_event_totals": (
                raw_event_totals
            ),
            "architecture_specific_metrics": {
                "direct_opposite_polarity_changes": (
                    self.direct_opposite_polarity_changes
                ),
                "neutral_state_exits": (
                    self.neutral_state_exits
                ),
                "gated_cycles": (
                    self.gated_cycles
                ),
            },
            "comparison_metrics": {
                "semantic_completion_ratio": (
                    semantic_completion_ratio
                ),
                "semantic_output_match": (
                    semantic_output_match
                ),
                "completion_ticks": (
                    self.processor_cycles
                ),
                "mean_latency_ticks": (
                    mean_latency_ticks
                ),
                "p95_latency_ticks": (
                    p95_latency_ticks
                ),
                "maximum_latency_ticks": (
                    maximum_latency_ticks
                ),
                "throughput_commands_per_tick": (
                    throughput_commands_per_tick
                ),
                "logical_state_changes": (
                    self.logical_state_changes
                ),
                "encoded_bit_toggles": (
                    self.encoded_bit_toggles
                ),
                "processor_cycles": (
                    self.processor_cycles
                ),
                "active_clocked_cycles": (
                    self.active_clocked_cycles
                ),
                "active_clock_fraction": (
                    active_clock_fraction
                ),
            },
            "final_state": {
                "ternary_states": list(
                    self.states
                ),
            },
            "command_trace": (
                self.command_trace
            ),
            "cycle_trace": (
                self.cycle_trace
            ),
        }

        result = dict(
            digest_payload
        )

        result[
            "architecture_result_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                digest_payload
            )
        )

        return result


def execute_direct_ternary_reference(
    workload_package: Mapping[str, Any],
) -> dict[str, Any]:
    """Execute one workload on the direct ternary baseline."""

    validate_workload_package(
        workload_package
    )

    profile = workload_package[
        "workload_profile"
    ]

    if (
        profile["issue_policy"]
        != ISSUE_POLICY_TRANSACTION_SERIAL
    ):
        raise DirectTernaryError(
            "direct ternary reference requires transaction_serial"
        )

    processor = DirectTernaryReference(
        num_cells=profile[
            "num_cells"
        ]
    )

    for command in workload_package[
        "commands"
    ]:
        processor.execute_command(
            command,
            max_completion_cycles=(
                profile[
                    "max_completion_cycles_per_command"
                ]
            ),
        )

    processor.execute_cooldown(
        profile[
            "final_cooldown_cycles"
        ]
    )

    return processor.build_result(
        workload_package=workload_package
    )


def _raises_direct_ternary_error(
    callback: Any,
) -> bool:
    try:
        callback()
    except DirectTernaryError:
        return True

    return False


def run_self_test() -> dict[str, Any]:
    workload = build_workload_package(
        WorkloadProfile()
    )

    result_a = execute_direct_ternary_reference(
        workload
    )

    result_b = execute_direct_ternary_reference(
        workload
    )

    metrics = result_a[
        "comparison_metrics"
    ]

    raw = result_a[
        "raw_event_totals"
    ]

    specific = result_a[
        "architecture_specific_metrics"
    ]

    command_count = workload[
        "workload_profile"
    ]["command_count"]

    cooldown_cycles = workload[
        "workload_profile"
    ]["final_cooldown_cycles"]

    expected_cycles = (
        command_count
        + cooldown_cycles
    )

    num_cells = workload[
        "workload_profile"
    ]["num_cells"]

    expected_state_changes = 138
    expected_encoded_bit_toggles = 146
    expected_direct_opposite_changes = 122
    expected_neutral_state_exits = 16
    expected_clocked_state_bits = (
        expected_state_changes
        * STATE_BITS_PER_CELL
    )
    expected_gated_cycles = (
        expected_cycles
        - expected_state_changes
    )
    expected_active_fraction = (
        expected_state_changes
        / expected_cycles
    )

    invalid_target_command = {
        "command_index": 0,
        "cell_id": 0,
        "semantic_target": "INVALID_TARGET",
    }

    invalid_cell_command = {
        "command_index": 0,
        "cell_id": num_cells,
        "semantic_target": NEGATIVE_TARGET,
    }

    probe = DirectTernaryReference(
        num_cells=num_cells
    )

    checks = {
        "architecture_id_correct": (
            result_a["architecture_id"]
            == ARCHITECTURE_ID
        ),
        "workload_digest_preserved": (
            result_a["workload_sha256"]
            == workload["workload_sha256"]
        ),
        "all_commands_issued": (
            raw["semantic_commands_issued"]
            == command_count
        ),
        "all_commands_completed": (
            raw["semantic_commands_completed"]
            == command_count
        ),
        "semantic_completion_ratio_one": (
            metrics["semantic_completion_ratio"]
            == 1.0
        ),
        "semantic_output_match_one": (
            metrics["semantic_output_match"]
            == 1.0
        ),
        "one_command_cycle_each": (
            metrics["mean_latency_ticks"]
            == 1.0
            and metrics["p95_latency_ticks"]
            == 1.0
            and metrics["maximum_latency_ticks"]
            == 1
        ),
        "expected_total_cycle_count": (
            raw["processor_cycles"]
            == expected_cycles
        ),
        "expected_state_change_count": (
            raw["logical_state_changes"]
            == expected_state_changes
        ),
        "expected_encoded_toggle_count": (
            raw["encoded_bit_toggles"]
            == expected_encoded_bit_toggles
        ),
        "expected_direct_opposite_change_count": (
            specific["direct_opposite_polarity_changes"]
            == expected_direct_opposite_changes
        ),
        "expected_neutral_state_exit_count": (
            specific["neutral_state_exits"]
            == expected_neutral_state_exits
        ),
        "state_clock_active_only_on_write": (
            raw["active_clocked_cycles"]
            == raw["logical_state_changes"]
            == expected_state_changes
        ),
        "clocked_state_bits_two_per_write": (
            raw["clocked_state_bits"]
            == expected_clocked_state_bits
        ),
        "register_write_bits_two_per_write": (
            raw["register_write_bits"]
            == expected_clocked_state_bits
        ),
        "gated_cycles_exact": (
            specific["gated_cycles"]
            == expected_gated_cycles
        ),
        "active_clock_fraction_exact": (
            math.isclose(
                metrics["active_clock_fraction"],
                expected_active_fraction,
                rel_tol=0.0,
                abs_tol=1e-15,
            )
        ),
        "comparison_event_per_command": (
            raw["comparison_events"]
            == command_count
        ),
        "control_event_per_cycle": (
            raw["control_events"]
            == expected_cycles
        ),
        "unsupported_cost_events_zero": all(
            raw[event_field] == 0
            for event_field in (
                "queue_reads",
                "queue_writes",
                "lut_reads_32",
                "fixed_point_multiplies_32x32",
                "fixed_point_accumulates_64",
                "fixed_point_adds_32",
                "fixed_point_compares_32",
            )
        ),
        "cycle_trace_length_exact": (
            len(result_a["cycle_trace"])
            == expected_cycles
        ),
        "command_trace_length_exact": (
            len(result_a["command_trace"])
            == command_count
        ),
        "no_automatic_neutral_insertion": all(
            not (
                row["state_before"]
                in (TERNARY_NEGATIVE, TERNARY_POSITIVE)
                and row["state_after"]
                == TERNARY_NEUTRAL
            )
            for row in result_a["command_trace"]
        ),
        "encoding_toggle_accounting_exact": (
            sum(
                row["encoded_bit_toggles"]
                for row in result_a["command_trace"]
            )
            == raw["encoded_bit_toggles"]
        ),
        "deterministic_result_digest_repeat": (
            result_a["architecture_result_sha256"]
            == result_b["architecture_result_sha256"]
        ),
        "deterministic_result_byte_repeat": (
            canonical_json_bytes(result_a)
            == canonical_json_bytes(result_b)
        ),
        "invalid_target_rejected": (
            _raises_direct_ternary_error(
                lambda: probe.execute_command(
                    invalid_target_command,
                    max_completion_cycles=64,
                )
            )
        ),
        "invalid_cell_rejected": (
            _raises_direct_ternary_error(
                lambda: probe.execute_command(
                    invalid_cell_command,
                    max_completion_cycles=64,
                )
            )
        ),
    }

    status = (
        "PASS"
        if all(checks.values())
        else "FAIL"
    )

    return {
        "schema": ARCHITECTURE_SELF_TEST_SCHEMA,
        "status": status,
        "check_count": len(checks),
        "checks": checks,
        "workload_sha256": (
            workload["workload_sha256"]
        ),
        "architecture_result_sha256": (
            result_a[
                "architecture_result_sha256"
            ]
        ),
        "summary": {
            "command_count": command_count,
            "completion_ticks": (
                metrics["completion_ticks"]
            ),
            "logical_state_changes": (
                raw["logical_state_changes"]
            ),
            "encoded_bit_toggles": (
                raw["encoded_bit_toggles"]
            ),
            "direct_opposite_polarity_changes": (
                specific[
                    "direct_opposite_polarity_changes"
                ]
            ),
            "neutral_state_exits": (
                specific["neutral_state_exits"]
            ),
            "active_clocked_cycles": (
                raw["active_clocked_cycles"]
            ),
            "clocked_state_bits": (
                raw["clocked_state_bits"]
            ),
            "gated_cycles": (
                specific["gated_cycles"]
            ),
            "active_clock_fraction": (
                metrics["active_clock_fraction"]
            ),
        },
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Execute the Direct Ternary Reference "
            "for the FRP Comparative Architecture "
            "Benchmark Suite."
        )
    )

    parser.add_argument(
        "--workload",
        type=Path,
        help=(
            "Optional validated semantic workload "
            "JSON package. The default workload "
            "profile is used when omitted."
        ),
    )

    parser.add_argument(
        "--write",
        type=Path,
        help=(
            "Optional path for the architecture "
            "result JSON."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run direct ternary reference self-tests."
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


def main() -> int:
    args = build_parser().parse_args()

    try:
        if args.self_test:
            result = run_self_test()

        else:
            workload = (
                _load_workload_package(
                    args.workload
                )
                if args.workload
                else build_workload_package(
                    WorkloadProfile()
                )
            )

            result = execute_direct_ternary_reference(
                workload
            )

        if args.write:
            _write_json(
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
            if args.self_test:
                print(
                    "FRP COMPARATIVE DIRECT "
                    "TERNARY REFERENCE SELF TEST"
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
                    "architecture_result_sha256="
                    f"{result['architecture_result_sha256']}"
                )

            else:
                metrics = result[
                    "comparison_metrics"
                ]

                raw = result[
                    "raw_event_totals"
                ]

                specific = result[
                    "architecture_specific_metrics"
                ]

                print(
                    "FRP COMPARATIVE DIRECT "
                    "TERNARY REFERENCE"
                )

                print(
                    "architecture_id="
                    f"{result['architecture_id']}"
                )

                print(
                    "workload_sha256="
                    f"{result['workload_sha256']}"
                )

                print(
                    "completion_ticks="
                    f"{metrics['completion_ticks']}"
                )

                print(
                    "semantic_output_match="
                    f"{metrics['semantic_output_match']}"
                )

                print(
                    "logical_state_changes="
                    f"{raw['logical_state_changes']}"
                )

                print(
                    "encoded_bit_toggles="
                    f"{raw['encoded_bit_toggles']}"
                )

                print(
                    "direct_opposite_polarity_changes="
                    f"{specific['direct_opposite_polarity_changes']}"
                )

                print(
                    "clocked_state_bits="
                    f"{raw['clocked_state_bits']}"
                )

        return (
            0
            if (
                not args.self_test
                or result["status"] == "PASS"
            )
            else 1
        )

    except (
        DirectTernaryError,
        CostModelError,
        WorkloadError,
    ) as exc:
        raise SystemExit(
            "direct ternary reference error: "
            f"{exc}"
        ) from exc


if __name__ == "__main__":
    raise SystemExit(main())

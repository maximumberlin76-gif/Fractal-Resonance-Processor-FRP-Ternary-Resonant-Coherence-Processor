#!/usr/bin/env python3
"""Direct ternary adapter for the FRP nonlinear multitask benchmark.

The first benchmark stage is hard-locked to ``scheduler_mode = free``. The
adapter executes the shared architecture-neutral nonlinear problem and commits
semantic states directly in {-1, 0, 1}. Direct -1 <-> +1 changes are allowed in
one logical update. No mandatory neutral insertion, tick-separated neutral
routing, 7/1, 1/7, or FRP kernel behavior is applied here.
"""

from __future__ import annotations

import copy
import hashlib
import sys
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence

ADAPTER_SCHEMA = "frp.benchmark.nonlinear_multitask.direct_ternary_adapter.v1"
STEP_SCHEMA = "frp.benchmark.nonlinear_multitask.direct_ternary_step.v1"
CONTRACT_SCHEMA = "frp.benchmark.nonlinear_multitask.direct_ternary_contract.v1"
SELF_TEST_SCHEMA = (
    "frp.benchmark.nonlinear_multitask.direct_ternary_adapter.self_test.v1"
)

ARCHITECTURE_ID = "direct_ternary_reference"
ARCHITECTURE_NAME = "Direct Ternary Reference"
EXPECTED_SCHEDULER_MODE = "free"

TERNARY_STATES = (-1, 0, 1)
TERNARY_ENCODING = {-1: 0b11, 0: 0b00, 1: 0b01}
RESERVED_TERNARY_CODE = 0b10

SEMANTIC_BITS_PER_LANE = 2
REGISTER_FIELD_WIDTHS = (
    ("semantic_states", SEMANTIC_BITS_PER_LANE),
    ("phase_words", 32),
    ("frequency_target_q16", 32),
    ("frequency_current_q16", 32),
    ("heat_q16", 32),
    ("delayed_coupling_q16", 32),
)
STATE_REGISTER_BITS_PER_LANE = sum(width for _, width in REGISTER_FIELD_WIDTHS)

EVENT_PACKET_PHASE_ORDER = (
    "decode_gamma_and_thermal_factor",
    "phase_coupling",
    "delay_frequency_and_phase_update",
    "thermal_field_update",
    "state_projection",
    "direct_ternary_register_commit",
)

ADAPTER_DIR = Path(__file__).resolve().parent
ARCHITECTURE_COMPARISON_DIR = Path(__file__).resolve().parents[2] / "architecture_comparison"

for import_path in (ADAPTER_DIR, ARCHITECTURE_COMPARISON_DIR):
    if str(import_path) not in sys.path:
        sys.path.insert(0, str(import_path))

try:
    from common_cost_model import EVENT_FIELDS, empty_event_counts, validate_event_counts
except ImportError as exc:
    raise RuntimeError(
        "unable to import the shared architecture-comparison cost model"
    ) from exc

try:
    from common_nonlinear_problem import (
        PHASE_MOD,
        ProblemDomainState,
        ProblemStepResult,
        build_problem_state,
        canonical_json_bytes,
        problem_operation_shape,
        sha256_hex,
        step_problem_domain,
        validate_problem_profile,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the shared nonlinear multitask problem model"
    ) from exc


class DirectTernaryAdapterError(ValueError):
    """Raised when the direct ternary adapter contract is violated."""


def fail(message: str) -> NoReturn:
    raise DirectTernaryAdapterError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def require_int(value: Any, name: str, minimum: int | None = None) -> int:
    require(
        not isinstance(value, bool) and isinstance(value, int),
        f"{name} must be an integer",
    )
    if minimum is not None:
        require(value >= minimum, f"{name} must be >= {minimum}")
    return value


def ternary_code(state: int) -> int:
    require(
        not isinstance(state, bool)
        and isinstance(state, int)
        and state in TERNARY_ENCODING,
        "semantic state must remain in {-1, 0, 1}",
    )
    return TERNARY_ENCODING[state]


def ternary_toggle_count(before: Sequence[int], after: Sequence[int]) -> int:
    require(len(before) == len(after), "semantic state vector length mismatch")
    return sum(
        (ternary_code(previous) ^ ternary_code(current)).bit_count()
        for previous, current in zip(before, after)
    )


def ternary_transition_metrics(
    before: Sequence[int],
    after: Sequence[int],
) -> dict[str, int]:
    require(len(before) == len(after), "semantic state vector length mismatch")

    state_changes = 0
    direct_opposite = 0
    neutral_entries = 0
    neutral_exits = 0

    for previous, current in zip(before, after):
        ternary_code(previous)
        ternary_code(current)

        if previous == current:
            continue

        state_changes += 1
        if previous in (-1, 1) and current == -previous:
            direct_opposite += 1
        if previous != 0 and current == 0:
            neutral_entries += 1
        if previous == 0 and current != 0:
            neutral_exits += 1

    return {
        "semantic_state_changes": state_changes,
        "direct_opposite_polarity_changes": direct_opposite,
        "neutral_state_entries": neutral_entries,
        "neutral_state_exits": neutral_exits,
        "unchanged_semantic_lanes": len(before) - state_changes,
        "encoded_bit_toggles": ternary_toggle_count(before, after),
    }


def full_state_register_bits(domain_size: int) -> int:
    return require_int(domain_size, "domain_size", 1) * STATE_REGISTER_BITS_PER_LANE


def persistent_register_activity(
    previous_state: ProblemDomainState,
    next_state: ProblemDomainState,
) -> dict[str, Any]:
    require(
        previous_state.domain_size == next_state.domain_size,
        "problem state domain size changed across one logical update",
    )

    size = previous_state.domain_size
    field_activity: dict[str, dict[str, int]] = {}
    changed_field_lanes = 0
    active_bits = 0

    for field_name, width in REGISTER_FIELD_WIDTHS:
        before = tuple(getattr(previous_state, field_name))
        after = tuple(getattr(next_state, field_name))
        require(
            len(before) == len(after) == size,
            f"{field_name} vector length mismatch",
        )

        changed = sum(
            1
            for previous, current in zip(before, after)
            if previous != current
        )
        field_bits = changed * width
        changed_field_lanes += changed
        active_bits += field_bits

        field_activity[field_name] = {
            "field_width_bits": width,
            "changed_lanes": changed,
            "unchanged_lanes": size - changed,
            "active_clocked_bits": field_bits,
            "register_write_bits": field_bits,
        }

    full_bits = full_state_register_bits(size)
    require(
        0 <= active_bits <= full_bits,
        "active clocked state-bit count is outside the full register envelope",
    )

    return {
        "field_activity": field_activity,
        "changed_register_field_lanes": changed_field_lanes,
        "active_clocked_state_bits": active_bits,
        "register_write_bits": active_bits,
        "full_state_register_bits": full_bits,
        "write_enabled_state_bits_saved": full_bits - active_bits,
        "write_enable_comparison_events": size * len(REGISTER_FIELD_WIDTHS),
        "active_write_enable_control_events": changed_field_lanes,
    }


def _base_packet() -> dict[str, int]:
    packet = empty_event_counts()
    packet["comparison_events"] = 1
    packet["control_events"] = 1
    return packet


def _build_event_packets(
    previous_state: ProblemDomainState,
    problem_result: ProblemStepResult,
) -> tuple[tuple[dict[str, int], ...], dict[str, Any], dict[str, int]]:
    require(
        previous_state.domain_size == problem_result.state.domain_size,
        "problem state domain size changed across one logical update",
    )

    size = previous_state.domain_size
    shape = problem_operation_shape(size)
    phase_pairs = shape["phase_pair_interactions"]
    thermal_pairs = shape["thermal_pair_interactions"]

    require(phase_pairs == size * (size - 1), "phase interaction shape mismatch")
    require(
        thermal_pairs == size * (size - 1),
        "thermal interaction shape mismatch",
    )

    activity = persistent_register_activity(previous_state, problem_result.state)
    transitions = ternary_transition_metrics(
        previous_state.semantic_states,
        problem_result.state.semantic_states,
    )
    require(
        transitions["semantic_state_changes"] == problem_result.state_change_count,
        "shared problem state-change count mismatch",
    )

    decode = _base_packet()
    decode["fixed_point_adds_32"] = 2 * size
    decode["fixed_point_multiplies_32x32"] = size
    decode["fixed_point_compares_32"] = 2 * size

    phase = _base_packet()
    phase["lut_reads_32"] = phase_pairs
    phase["fixed_point_multiplies_32x32"] = 3 * phase_pairs + size
    phase["fixed_point_accumulates_64"] = phase_pairs
    phase["fixed_point_adds_32"] = 2 * phase_pairs

    delay_frequency_phase = _base_packet()
    delay_frequency_phase["fixed_point_multiplies_32x32"] = 4 * size
    delay_frequency_phase["fixed_point_adds_32"] = 8 * size
    delay_frequency_phase["fixed_point_compares_32"] = size

    thermal = _base_packet()
    thermal["fixed_point_multiplies_32x32"] = thermal_pairs + 3 * size
    thermal["fixed_point_accumulates_64"] = thermal_pairs
    thermal["fixed_point_adds_32"] = thermal_pairs + 4 * size
    thermal["fixed_point_compares_32"] = size

    projection = _base_packet()
    projection["lut_reads_32"] = size
    projection["fixed_point_compares_32"] = 2 * size

    commit = _base_packet()
    commit["encoded_bit_toggles"] = transitions["encoded_bit_toggles"]
    commit["clocked_state_bits"] = activity["active_clocked_state_bits"]
    commit["register_write_bits"] = activity["register_write_bits"]
    commit["comparison_events"] = (
        size + 1 + activity["write_enable_comparison_events"]
    )
    commit["control_events"] = (
        1 + activity["active_write_enable_control_events"]
    )

    packets = (
        decode,
        phase,
        delay_frequency_phase,
        thermal,
        projection,
        commit,
    )
    require(len(packets) == len(EVENT_PACKET_PHASE_ORDER), "event packet count mismatch")

    return (
        tuple(validate_event_counts(packet) for packet in packets),
        activity,
        transitions,
    )


def aggregate_event_packets(
    event_packets: Sequence[Mapping[str, Any]],
) -> dict[str, int]:
    totals = empty_event_counts()
    for packet in event_packets:
        validated = validate_event_counts(packet)
        for field in EVENT_FIELDS:
            totals[field] += validated[field]
    return totals


@dataclass(frozen=True)
class DirectTernaryStepResult:
    architecture_id: str
    architecture_name: str
    scheduler_mode: str
    semantic_states: tuple[int, ...]
    phase_words: tuple[int, ...]
    event_packets: tuple[dict[str, int], ...]
    logical_update_metadata: Mapping[str, Any]

    def to_dict(self) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "schema": STEP_SCHEMA,
            "architecture_id": self.architecture_id,
            "architecture_name": self.architecture_name,
            "scheduler_mode": self.scheduler_mode,
            "semantic_states": list(self.semantic_states),
            "phase_words": list(self.phase_words),
            "event_packet_phase_order": list(EVENT_PACKET_PHASE_ORDER),
            "event_packets": [dict(packet) for packet in self.event_packets],
            "logical_update_metadata": copy.deepcopy(
                dict(self.logical_update_metadata)
            ),
            "winner_assertions": [],
        }
        payload["adapter_step_sha256"] = sha256_hex(canonical_json_bytes(payload))
        return payload


class DirectTernaryAdapter:
    """Direct ternary execution adapter for one nonlinear domain."""

    def __init__(self, profile: Mapping[str, Any], initialization: Any) -> None:
        validate_problem_profile(profile)
        require(
            profile.get("scheduler_mode") == EXPECTED_SCHEDULER_MODE,
            "initial benchmark scheduler_mode must be free",
        )

        self.profile = copy.deepcopy(dict(profile))
        self.problem_state = build_problem_state(initialization)
        self.domain_size = self.problem_state.domain_size
        self.domain_index = self.problem_state.domain_index
        self.nonlinearity_class = self.problem_state.nonlinearity_class

        require(
            self.domain_size in (8, 16, 32),
            "domain_size must be 8, 16, or 32",
        )
        require(
            all(state in TERNARY_STATES for state in self.problem_state.semantic_states),
            "initial semantic state escaped {-1, 0, 1}",
        )

        self.logical_updates = 0
        self.event_totals = empty_event_counts()
        self.semantic_state_changes = 0
        self.direct_opposite_polarity_changes = 0
        self.neutral_state_entries = 0
        self.neutral_state_exits = 0
        self.total_write_enabled_state_bits_saved = 0
        self.total_changed_register_field_lanes = 0
        self.step_trace_sha256: list[str] = []

    @property
    def semantic_states(self) -> tuple[int, ...]:
        return self.problem_state.semantic_states

    @property
    def phase_words(self) -> tuple[int, ...]:
        return self.problem_state.phase_words

    def step(
        self,
        *,
        gamma_targets_q16: Sequence[int],
    ) -> DirectTernaryStepResult:
        previous_state = self.problem_state
        require(
            previous_state.logical_iteration == self.logical_updates,
            "logical update counter diverged from shared problem state",
        )

        problem_result = step_problem_domain(
            self.profile,
            previous_state,
            gamma_targets_q16=gamma_targets_q16,
        )

        require(
            problem_result.state.logical_iteration
            == previous_state.logical_iteration + 1,
            "shared problem did not advance exactly one logical iteration",
        )
        require(
            problem_result.state.domain_index == self.domain_index,
            "shared problem changed domain_index",
        )
        require(
            problem_result.state.domain_size == self.domain_size,
            "shared problem changed domain_size",
        )
        require(
            all(state in TERNARY_STATES for state in problem_result.state.semantic_states),
            "shared problem escaped direct ternary state domain",
        )
        require(
            all(0 <= word < PHASE_MOD for word in problem_result.state.phase_words),
            "shared problem escaped PHASE_U32",
        )

        event_packets, activity, transitions = _build_event_packets(
            previous_state,
            problem_result,
        )
        event_totals = aggregate_event_packets(event_packets)

        for field in EVENT_FIELDS:
            self.event_totals[field] += event_totals[field]

        self.semantic_state_changes += transitions["semantic_state_changes"]
        self.direct_opposite_polarity_changes += transitions[
            "direct_opposite_polarity_changes"
        ]
        self.neutral_state_entries += transitions["neutral_state_entries"]
        self.neutral_state_exits += transitions["neutral_state_exits"]
        self.total_write_enabled_state_bits_saved += activity[
            "write_enabled_state_bits_saved"
        ]
        self.total_changed_register_field_lanes += activity[
            "changed_register_field_lanes"
        ]

        logical_update_id = (
            f"{ARCHITECTURE_ID}:"
            f"domain-{self.domain_index}:"
            f"iteration-{previous_state.logical_iteration}"
        )
        problem_step_payload = problem_result.to_dict()

        metadata: dict[str, Any] = {
            "logical_update_id": logical_update_id,
            "domain_index": self.domain_index,
            "domain_size": self.domain_size,
            "nonlinearity_class": self.nonlinearity_class,
            "logical_iteration_before": previous_state.logical_iteration,
            "logical_iteration_after": problem_result.state.logical_iteration,
            "direct_ternary_state_domain": [-1, 0, 1],
            "direct_ternary_encoding": {
                "-1": "11",
                "0": "00",
                "1": "01",
                "reserved": "10",
            },
            "automatic_neutral_insertion": False,
            "opposite_polarity_transition": "direct_single_logical_update",
            "tick_separated_neutral_route": False,
            "scheduler_modulation": False,
            "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
            "full_state_register_bits": activity["full_state_register_bits"],
            "active_clocked_state_bits": activity["active_clocked_state_bits"],
            "actual_register_write_bits": activity["register_write_bits"],
            "write_enabled_state_bits_saved": activity[
                "write_enabled_state_bits_saved"
            ],
            "changed_register_field_lanes": activity[
                "changed_register_field_lanes"
            ],
            "write_enable_comparison_events": activity[
                "write_enable_comparison_events"
            ],
            "active_write_enable_control_events": activity[
                "active_write_enable_control_events"
            ],
            "persistent_register_field_activity": copy.deepcopy(
                activity["field_activity"]
            ),
            "semantic_state_changes": transitions["semantic_state_changes"],
            "direct_opposite_polarity_changes": transitions[
                "direct_opposite_polarity_changes"
            ],
            "neutral_state_entries": transitions["neutral_state_entries"],
            "neutral_state_exits": transitions["neutral_state_exits"],
            "unchanged_semantic_lanes": transitions["unchanged_semantic_lanes"],
            "semantic_encoded_bit_toggles": transitions["encoded_bit_toggles"],
            "event_packet_count": len(event_packets),
            "event_packet_phase_order": list(EVENT_PACKET_PHASE_ORDER),
            "event_totals": event_totals,
            "problem_step_sha256": problem_step_payload["problem_step_sha256"],
            "winner_assertions": [],
        }

        result = DirectTernaryStepResult(
            architecture_id=ARCHITECTURE_ID,
            architecture_name=ARCHITECTURE_NAME,
            scheduler_mode=EXPECTED_SCHEDULER_MODE,
            semantic_states=problem_result.state.semantic_states,
            phase_words=problem_result.state.phase_words,
            event_packets=event_packets,
            logical_update_metadata=metadata,
        )
        result_payload = result.to_dict()

        self.problem_state = problem_result.state
        self.logical_updates += 1
        self.step_trace_sha256.append(result_payload["adapter_step_sha256"])
        return result

    def snapshot(self) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "schema": ADAPTER_SCHEMA,
            "architecture_id": ARCHITECTURE_ID,
            "architecture_name": ARCHITECTURE_NAME,
            "scheduler_mode": EXPECTED_SCHEDULER_MODE,
            "domain_size": self.domain_size,
            "domain_index": self.domain_index,
            "nonlinearity_class": self.nonlinearity_class,
            "logical_updates": self.logical_updates,
            "semantic_states": list(self.problem_state.semantic_states),
            "phase_words": list(self.problem_state.phase_words),
            "event_totals": dict(self.event_totals),
            "semantic_state_changes": self.semantic_state_changes,
            "direct_opposite_polarity_changes": self.direct_opposite_polarity_changes,
            "neutral_state_entries": self.neutral_state_entries,
            "neutral_state_exits": self.neutral_state_exits,
            "total_write_enabled_state_bits_saved": (
                self.total_write_enabled_state_bits_saved
            ),
            "total_changed_register_field_lanes": (
                self.total_changed_register_field_lanes
            ),
            "step_trace_sha256": list(self.step_trace_sha256),
            "winner_assertions": [],
        }
        payload["adapter_snapshot_sha256"] = sha256_hex(
            canonical_json_bytes(payload)
        )
        return payload


def build_direct_ternary_contract(profile: Mapping[str, Any]) -> dict[str, Any]:
    validate_problem_profile(profile)
    require(
        profile.get("scheduler_mode") == EXPECTED_SCHEDULER_MODE,
        "initial benchmark scheduler_mode must be free",
    )

    payload: dict[str, Any] = {
        "schema": CONTRACT_SCHEMA,
        "architecture_id": ARCHITECTURE_ID,
        "architecture_name": ARCHITECTURE_NAME,
        "scheduler_mode": EXPECTED_SCHEDULER_MODE,
        "execution_model": (
            "direct_ternary_fixed_point_realization_of_the_shared_nonlinear_problem"
        ),
        "semantic_output_domain": [-1, 0, 1],
        "phase_output_domain": "PHASE_U32",
        "direct_ternary_encoding": {
            "-1": "11",
            "0": "00",
            "1": "01",
            "reserved": "10",
        },
        "semantic_bits_per_lane_for_common_cost_accounting": (
            SEMANTIC_BITS_PER_LANE
        ),
        "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
        "persistent_register_fields": [
            {"field_name": name, "field_width_bits": width}
            for name, width in REGISTER_FIELD_WIDTHS
        ],
        "event_packet_phase_order": list(EVENT_PACKET_PHASE_ORDER),
        "arithmetic_operation_rule": (
            "identical declared shared-problem arithmetic event counts to the "
            "binary references"
        ),
        "native_ternary_semantic_rule": (
            "semantic state is carried directly in {-1,0,1} and any "
            "state-to-state transition may commit in one logical update"
        ),
        "common_cost_normalization_rule": (
            "because the shared cost model has no trit event class, ternary "
            "semantic register activity uses the repository-established "
            "two-bit encoding only for normalized event accounting"
        ),
        "write_enable_rule": (
            "a persistent field-lane register is clocked and written only "
            "when its next value differs from its current value"
        ),
        "change_detection_rule": (
            "one write-enable comparison event per persistent register field "
            "per lane per logical update"
        ),
        "active_write_enable_control_rule": (
            "one additional control event per changed persistent register "
            "field-lane"
        ),
        "opposite_polarity_transition_rule": (
            "-1 <-> +1 may commit directly in one logical update"
        ),
        "automatic_neutral_insertion": False,
        "tick_separated_neutral_route": False,
        "scheduler_7_1_enabled": False,
        "scheduler_1_7_enabled": False,
        "mandatory_frp_neutral_routing": False,
        "frp_kernel_imported": False,
        "external_thermal_ceiling_applied_here": False,
        "convergence_tracking_applied_here": False,
        "winner_assertions": [],
    }
    payload["direct_ternary_contract_sha256"] = sha256_hex(
        canonical_json_bytes(payload)
    )
    return payload


def _synthetic_initialization() -> Any:
    class SyntheticInitialization:
        domain_size = 8
        domain_index = 0
        nonlinearity_class = "medium"
        initial_states = (-1, 0, 1, -1, 0, 1, -1, 0)
        initial_phase_words = tuple(
            (index * (PHASE_MOD // 8) + (1 << 20)) % PHASE_MOD
            for index in range(8)
        )
        initial_frequency_target_q16 = tuple(1 << 16 for _ in range(8))
        initial_frequency_current_q16 = tuple(1 << 16 for _ in range(8))
        initial_heat_q16 = tuple(3277 for _ in range(8))

    return SyntheticInitialization()


def _self_test_gamma_targets(tick: int, size: int) -> tuple[int, ...]:
    scale = 3277
    span = 2 * scale + 1
    values = []

    for cell_index in range(size):
        digest = hashlib.sha256(
            f"direct-ternary-adapter-self-test:{tick}:{cell_index}".encode("utf-8")
        ).digest()
        raw = int.from_bytes(digest[:8], byteorder="big", signed=False)
        values.append((raw % span) - scale)

    return tuple(values)


def run_self_test(profile: Mapping[str, Any]) -> dict[str, Any]:
    validate_problem_profile(profile)

    require(
        RESERVED_TERNARY_CODE not in TERNARY_ENCODING.values(),
        "reserved ternary code collides with a valid state",
    )
    require(
        ternary_transition_metrics(
            (-1, 0, 1, -1),
            (1, 1, -1, 0),
        )
        == {
            "semantic_state_changes": 4,
            "direct_opposite_polarity_changes": 2,
            "neutral_state_entries": 1,
            "neutral_state_exits": 1,
            "unchanged_semantic_lanes": 0,
            "encoded_bit_toggles": 5,
        },
        "ternary transition metric self-test failed",
    )

    initial_state = build_problem_state(_synthetic_initialization())
    static_activity = persistent_register_activity(initial_state, initial_state)
    require(
        static_activity["active_clocked_state_bits"] == 0,
        "unchanged state must clock zero persistent state bits",
    )

    changed_semantic = list(initial_state.semantic_states)
    changed_semantic[0] = 1
    direct_opposite_state = replace(
        initial_state,
        semantic_states=tuple(changed_semantic),
    )
    direct_activity = persistent_register_activity(
        initial_state,
        direct_opposite_state,
    )
    require(
        direct_activity["active_clocked_state_bits"] == SEMANTIC_BITS_PER_LANE,
        "single ternary semantic-lane change must clock exactly two bits",
    )
    require(
        ternary_transition_metrics(
            initial_state.semantic_states,
            direct_opposite_state.semantic_states,
        )["direct_opposite_polarity_changes"]
        == 1,
        "direct opposite-polarity transition was not detected",
    )

    first = DirectTernaryAdapter(profile, _synthetic_initialization())
    second = DirectTernaryAdapter(profile, _synthetic_initialization())
    trace_a: list[dict[str, Any]] = []
    trace_b: list[dict[str, Any]] = []

    for tick in range(16):
        gamma_targets = _self_test_gamma_targets(tick, first.domain_size)
        result_a = first.step(gamma_targets_q16=gamma_targets)
        result_b = second.step(gamma_targets_q16=gamma_targets)
        payload_a = result_a.to_dict()
        payload_b = result_b.to_dict()

        require(
            payload_a == payload_b,
            "repeated adapter execution is not deterministic",
        )
        require(
            len(result_a.event_packets) == len(EVENT_PACKET_PHASE_ORDER),
            "self-test event packet count mismatch",
        )
        require(
            all(set(packet) == set(EVENT_FIELDS) for packet in result_a.event_packets),
            "self-test event packet field set mismatch",
        )
        require(
            all(
                packet["clocked_state_bits"] == 0
                and packet["register_write_bits"] == 0
                for packet in result_a.event_packets[:-1]
            ),
            "non-commit packets must clock and write zero persistent state bits",
        )

        metadata = result_a.logical_update_metadata
        commit = result_a.event_packets[-1]
        require(
            commit["clocked_state_bits"] == metadata["active_clocked_state_bits"],
            "commit clocked-state count mismatch",
        )
        require(
            commit["register_write_bits"] == metadata["actual_register_write_bits"],
            "commit register-write count mismatch",
        )
        require(
            metadata["write_enable_comparison_events"]
            == first.domain_size * len(REGISTER_FIELD_WIDTHS),
            "write-enable comparison count mismatch",
        )
        require(
            metadata["automatic_neutral_insertion"] is False,
            "direct ternary baseline must not insert neutral routes",
        )
        require(
            metadata["tick_separated_neutral_route"] is False,
            "direct ternary baseline must not use tick-separated routing",
        )
        require(
            metadata["scheduler_modulation"] is False,
            "direct ternary baseline must not use scheduler modulation",
        )
        require(
            all(state in TERNARY_STATES for state in result_a.semantic_states),
            "self-test escaped semantic {-1, 0, 1}",
        )
        require(
            all(0 <= word < PHASE_MOD for word in result_a.phase_words),
            "self-test escaped PHASE_U32",
        )

        trace_a.append(payload_a)
        trace_b.append(payload_b)

    require(trace_a == trace_b, "repeated adapter traces differ")

    snapshot_a = first.snapshot()
    snapshot_b = second.snapshot()
    require(snapshot_a == snapshot_b, "repeated adapter snapshots differ")
    require(
        snapshot_a["logical_updates"] == 16,
        "self-test logical update count mismatch",
    )

    contract_a = build_direct_ternary_contract(profile)
    contract_b = build_direct_ternary_contract(profile)
    require(contract_a == contract_b, "direct ternary contract is not deterministic")

    return {
        "schema": SELF_TEST_SCHEMA,
        "status": "PASS",
        "architecture_id": ARCHITECTURE_ID,
        "scheduler_mode": EXPECTED_SCHEDULER_MODE,
        "logical_updates": snapshot_a["logical_updates"],
        "event_packet_count_per_update": len(EVENT_PACKET_PHASE_ORDER),
        "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
        "semantic_state_changes": snapshot_a["semantic_state_changes"],
        "direct_opposite_polarity_changes": snapshot_a[
            "direct_opposite_polarity_changes"
        ],
        "neutral_state_entries": snapshot_a["neutral_state_entries"],
        "neutral_state_exits": snapshot_a["neutral_state_exits"],
        "trace_sha256": sha256_hex(canonical_json_bytes(trace_a)),
        "adapter_snapshot_sha256": snapshot_a["adapter_snapshot_sha256"],
        "direct_ternary_contract_sha256": contract_a[
            "direct_ternary_contract_sha256"
        ],
        "automatic_neutral_insertion": False,
        "tick_separated_neutral_route": False,
        "scheduler_modulation": False,
        "frp_kernel_imported": False,
        "winner_assertions": [],
    }

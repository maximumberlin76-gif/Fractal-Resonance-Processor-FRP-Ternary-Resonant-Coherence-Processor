#!/usr/bin/env python3
"""Binary synchronous adapter for the FRP nonlinear multitask benchmark.

The initial benchmark stage is hard-locked to ``scheduler_mode = free``. This
adapter executes the shared architecture-neutral nonlinear problem and exposes
binary-synchronous architecture event packets. It does not duplicate the FRP
kernel, apply the external thermal ceiling, track convergence, or rank results.
"""

from __future__ import annotations

import copy
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence

ADAPTER_SCHEMA = "frp.benchmark.nonlinear_multitask.binary_synchronous_adapter.v1"
STEP_SCHEMA = "frp.benchmark.nonlinear_multitask.binary_synchronous_step.v1"
CONTRACT_SCHEMA = (
    "frp.benchmark.nonlinear_multitask.binary_synchronous_contract.v1"
)
SELF_TEST_SCHEMA = (
    "frp.benchmark.nonlinear_multitask.binary_synchronous_adapter.self_test.v1"
)

ARCHITECTURE_ID = "binary_synchronous_reference"
ARCHITECTURE_NAME = "Binary Synchronous Reference"
EXPECTED_SCHEDULER_MODE = "free"

SEMANTIC_BITS_PER_LANE = 2
PHASE_BITS_PER_LANE = 32
FREQUENCY_TARGET_BITS_PER_LANE = 32
FREQUENCY_CURRENT_BITS_PER_LANE = 32
HEAT_BITS_PER_LANE = 32
DELAYED_COUPLING_BITS_PER_LANE = 32

STATE_REGISTER_BITS_PER_LANE = (
    SEMANTIC_BITS_PER_LANE
    + PHASE_BITS_PER_LANE
    + FREQUENCY_TARGET_BITS_PER_LANE
    + FREQUENCY_CURRENT_BITS_PER_LANE
    + HEAT_BITS_PER_LANE
    + DELAYED_COUPLING_BITS_PER_LANE
)

SEMANTIC_TO_BINARY_CODE = {
    -1: 0b11,
    0: 0b00,
    1: 0b01,
}

RESERVED_BINARY_CODE = 0b10

EVENT_PACKET_PHASE_ORDER = (
    "decode_gamma_and_thermal_factor",
    "phase_coupling",
    "delay_frequency_and_phase_update",
    "thermal_field_update",
    "state_projection",
    "synchronous_register_commit",
)

ADAPTER_DIR = Path(__file__).resolve().parent
ARCHITECTURE_COMPARISON_DIR = (
    Path(__file__).resolve().parents[2]
    / "architecture_comparison"
)

if str(ADAPTER_DIR) not in sys.path:
    sys.path.insert(0, str(ADAPTER_DIR))

if str(ARCHITECTURE_COMPARISON_DIR) not in sys.path:
    sys.path.insert(0, str(ARCHITECTURE_COMPARISON_DIR))

try:
    from common_cost_model import (
        EVENT_FIELDS,
        empty_event_counts,
        validate_event_counts,
    )
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


class BinarySynchronousAdapterError(ValueError):
    """Raised when the binary synchronous adapter contract is violated."""


def fail(message: str) -> NoReturn:
    raise BinarySynchronousAdapterError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def require_int(
    value: Any,
    name: str,
    minimum: int | None = None,
) -> int:
    require(
        not isinstance(value, bool) and isinstance(value, int),
        f"{name} must be an integer",
    )

    if minimum is not None:
        require(
            value >= minimum,
            f"{name} must be >= {minimum}",
        )

    return value


def semantic_code(state: int) -> int:
    require(
        not isinstance(state, bool)
        and isinstance(state, int)
        and state in SEMANTIC_TO_BINARY_CODE,
        "semantic state must remain in {-1, 0, 1}",
    )

    return SEMANTIC_TO_BINARY_CODE[state]


def semantic_toggle_count(
    before: Sequence[int],
    after: Sequence[int],
) -> int:
    require(
        len(before) == len(after),
        "semantic state vector length mismatch",
    )

    return sum(
        (
            semantic_code(previous)
            ^ semantic_code(current)
        ).bit_count()
        for previous, current in zip(before, after)
    )


def state_register_bits(domain_size: int) -> int:
    size = require_int(
        domain_size,
        "domain_size",
        1,
    )

    return size * STATE_REGISTER_BITS_PER_LANE


def _base_packet(domain_size: int) -> dict[str, int]:
    events = empty_event_counts()
    events["clocked_state_bits"] = state_register_bits(domain_size)
    events["comparison_events"] = 1
    events["control_events"] = 1
    return events


def _build_event_packets(
    previous_state: ProblemDomainState,
    problem_result: ProblemStepResult,
) -> tuple[dict[str, int], ...]:
    require(
        previous_state.domain_size == problem_result.state.domain_size,
        "problem state domain size changed across one logical update",
    )

    size = previous_state.domain_size
    shape = problem_operation_shape(size)

    phase_pairs = shape["phase_pair_interactions"]
    thermal_pairs = shape["thermal_pair_interactions"]

    require(
        phase_pairs == size * (size - 1),
        "phase interaction shape mismatch",
    )

    require(
        thermal_pairs == size * (size - 1),
        "thermal interaction shape mismatch",
    )

    decode = _base_packet(size)
    decode["fixed_point_adds_32"] = 2 * size
    decode["fixed_point_multiplies_32x32"] = size
    decode["fixed_point_compares_32"] = 2 * size

    phase = _base_packet(size)
    phase["lut_reads_32"] = phase_pairs
    phase["fixed_point_multiplies_32x32"] = (
        3 * phase_pairs
        + size
    )
    phase["fixed_point_accumulates_64"] = phase_pairs
    phase["fixed_point_adds_32"] = 2 * phase_pairs

    delay_frequency_phase = _base_packet(size)
    delay_frequency_phase["fixed_point_multiplies_32x32"] = 4 * size
    delay_frequency_phase["fixed_point_adds_32"] = 8 * size
    delay_frequency_phase["fixed_point_compares_32"] = size

    thermal = _base_packet(size)
    thermal["fixed_point_multiplies_32x32"] = (
        thermal_pairs
        + 3 * size
    )
    thermal["fixed_point_accumulates_64"] = thermal_pairs
    thermal["fixed_point_adds_32"] = (
        thermal_pairs
        + 4 * size
    )
    thermal["fixed_point_compares_32"] = size

    projection = _base_packet(size)
    projection["lut_reads_32"] = size
    projection["fixed_point_compares_32"] = 2 * size

    commit = _base_packet(size)
    commit["encoded_bit_toggles"] = semantic_toggle_count(
        previous_state.semantic_states,
        problem_result.state.semantic_states,
    )
    commit["register_write_bits"] = state_register_bits(size)
    commit["comparison_events"] = size + 1

    packets = (
        decode,
        phase,
        delay_frequency_phase,
        thermal,
        projection,
        commit,
    )

    require(
        len(packets) == len(EVENT_PACKET_PHASE_ORDER),
        "event packet count mismatch",
    )

    return tuple(
        validate_event_counts(packet)
        for packet in packets
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
class BinarySynchronousStepResult:
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
            "event_packets": [
                dict(packet)
                for packet in self.event_packets
            ],
            "logical_update_metadata": copy.deepcopy(
                dict(self.logical_update_metadata)
            ),
            "winner_assertions": [],
        }

        payload["adapter_step_sha256"] = sha256_hex(
            canonical_json_bytes(payload)
        )

        return payload


class BinarySynchronousAdapter:
    """Globally clocked binary execution adapter for one nonlinear domain."""

    def __init__(
        self,
        profile: Mapping[str, Any],
        initialization: Any,
    ) -> None:
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

        self.logical_updates = 0
        self.event_totals = empty_event_counts()
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
    ) -> BinarySynchronousStepResult:
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
            all(
                state in SEMANTIC_TO_BINARY_CODE
                for state in problem_result.state.semantic_states
            ),
            "shared problem escaped exact ternary semantic output domain",
        )

        require(
            all(
                0 <= phase_word < PHASE_MOD
                for phase_word in problem_result.state.phase_words
            ),
            "shared problem escaped PHASE_U32",
        )

        event_packets = _build_event_packets(
            previous_state,
            problem_result,
        )

        event_totals = aggregate_event_packets(event_packets)

        for field in EVENT_FIELDS:
            self.event_totals[field] += event_totals[field]

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
            "binary_semantic_encoding": {
                "-1": "11",
                "0": "00",
                "1": "01",
                "reserved": "10",
            },
            "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
            "state_register_bits_total": state_register_bits(
                self.domain_size
            ),
            "global_clocked_state_bits_per_packet": state_register_bits(
                self.domain_size
            ),
            "event_packet_count": len(event_packets),
            "event_packet_phase_order": list(EVENT_PACKET_PHASE_ORDER),
            "event_totals": event_totals,
            "state_change_count": problem_result.state_change_count,
            "semantic_encoded_bit_toggles": event_totals[
                "encoded_bit_toggles"
            ],
            "problem_step_sha256": problem_step_payload[
                "problem_step_sha256"
            ],
            "winner_assertions": [],
        }

        result = BinarySynchronousStepResult(
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
        self.step_trace_sha256.append(
            result_payload["adapter_step_sha256"]
        )

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
            "step_trace_sha256": list(self.step_trace_sha256),
            "winner_assertions": [],
        }

        payload["adapter_snapshot_sha256"] = sha256_hex(
            canonical_json_bytes(payload)
        )

        return payload


def build_binary_synchronous_contract(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
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
            "globally_clocked_binary_fixed_point_realization_of_the_shared_"
            "nonlinear_problem"
        ),
        "semantic_output_domain": [-1, 0, 1],
        "phase_output_domain": "PHASE_U32",
        "semantic_binary_encoding": {
            "-1": "11",
            "0": "00",
            "1": "01",
            "reserved": "10",
        },
        "semantic_bits_per_lane": SEMANTIC_BITS_PER_LANE,
        "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
        "globally_clocked_register_fields": [
            "semantic_state_2b",
            "phase_word_32b",
            "frequency_target_q16_32b",
            "frequency_current_q16_32b",
            "heat_q16_32b",
            "delayed_coupling_q16_32b",
        ],
        "event_packet_phase_order": list(EVENT_PACKET_PHASE_ORDER),
        "clock_rule": (
            "all declared persistent state bits are clocked once in every "
            "architecture event packet"
        ),
        "register_commit_rule": (
            "all declared persistent state registers are synchronously "
            "written at the final commit packet"
        ),
        "encoded_bit_toggle_rule": (
            "two-bit Hamming distance across semantic state encodings only"
        ),
        "phase_coupling_operation_rule": (
            "per directed pair: two fixed-point adds, one LUT read, three "
            "32x32 multiplies, and one 64-bit accumulate; plus one coupling "
            "scale multiply per lane"
        ),
        "thermal_coupling_operation_rule": (
            "per directed pair: one fixed-point add, one 32x32 multiply, "
            "and one 64-bit accumulate; plus three lane multiplies, four "
            "lane adds, and one lane compare"
        ),
        "delay_frequency_phase_operation_rule": (
            "per lane: four 32x32 multiplies, eight fixed-point adds, and "
            "one fixed-point compare"
        ),
        "state_projection_operation_rule": (
            "per lane: one LUT read and two fixed-point compares"
        ),
        "external_thermal_ceiling_applied_here": False,
        "convergence_tracking_applied_here": False,
        "frp_kernel_imported": False,
        "winner_assertions": [],
    }

    payload["binary_synchronous_contract_sha256"] = sha256_hex(
        canonical_json_bytes(payload)
    )

    return payload


def _synthetic_initialization() -> Any:
    class SyntheticInitialization:
        domain_size = 8
        domain_index = 0
        nonlinearity_class = "medium"
        initial_states = (
            -1,
            0,
            1,
            -1,
            0,
            1,
            -1,
            0,
        )
        initial_phase_words = tuple(
            (
                index * (PHASE_MOD // 8)
                + (1 << 20)
            )
            % PHASE_MOD
            for index in range(8)
        )
        initial_frequency_target_q16 = tuple(
            1 << 16
            for _ in range(8)
        )
        initial_frequency_current_q16 = tuple(
            1 << 16
            for _ in range(8)
        )
        initial_heat_q16 = tuple(
            3277
            for _ in range(8)
        )

    return SyntheticInitialization()


def _self_test_gamma_targets(
    tick: int,
    size: int,
) -> tuple[int, ...]:
    values = []
    scale = 3277
    span = 2 * scale + 1

    for cell_index in range(size):
        digest = hashlib.sha256(
            (
                f"binary-synchronous-adapter-self-test:"
                f"{tick}:"
                f"{cell_index}"
            ).encode("utf-8")
        ).digest()

        raw = int.from_bytes(
            digest[:8],
            byteorder="big",
            signed=False,
        )

        values.append(
            (raw % span) - scale
        )

    return tuple(values)


def run_self_test(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    validate_problem_profile(profile)

    first = BinarySynchronousAdapter(
        profile,
        _synthetic_initialization(),
    )

    second = BinarySynchronousAdapter(
        profile,
        _synthetic_initialization(),
    )

    trace_a: list[dict[str, Any]] = []
    trace_b: list[dict[str, Any]] = []

    for tick in range(16):
        gamma_targets = _self_test_gamma_targets(
            tick,
            first.domain_size,
        )

        result_a = first.step(
            gamma_targets_q16=gamma_targets,
        )

        result_b = second.step(
            gamma_targets_q16=gamma_targets,
        )

        payload_a = result_a.to_dict()
        payload_b = result_b.to_dict()

        require(
            payload_a == payload_b,
            "repeated adapter execution is not deterministic",
        )

        require(
            len(result_a.event_packets)
            == len(EVENT_PACKET_PHASE_ORDER),
            "self-test event packet count mismatch",
        )

        require(
            all(
                set(packet) == set(EVENT_FIELDS)
                for packet in result_a.event_packets
            ),
            "self-test event packet field set mismatch",
        )

        require(
            all(
                packet["clocked_state_bits"]
                == state_register_bits(first.domain_size)
                for packet in result_a.event_packets
            ),
            "binary synchronous packet did not clock the full state domain",
        )

        require(
            all(
                state in SEMANTIC_TO_BINARY_CODE
                for state in result_a.semantic_states
            ),
            "self-test escaped semantic {-1, 0, 1}",
        )

        require(
            all(
                0 <= phase_word < PHASE_MOD
                for phase_word in result_a.phase_words
            ),
            "self-test escaped PHASE_U32",
        )

        trace_a.append(payload_a)
        trace_b.append(payload_b)

    require(
        trace_a == trace_b,
        "repeated adapter traces differ",
    )

    snapshot_a = first.snapshot()
    snapshot_b = second.snapshot()

    require(
        snapshot_a == snapshot_b,
        "repeated adapter snapshots differ",
    )

    require(
        snapshot_a["logical_updates"] == 16,
        "self-test logical update count mismatch",
    )

    contract_a = build_binary_synchronous_contract(profile)
    contract_b = build_binary_synchronous_contract(profile)

    require(
        contract_a == contract_b,
        "binary synchronous contract is not deterministic",
    )

    return {
        "schema": SELF_TEST_SCHEMA,
        "status": "PASS",
        "architecture_id": ARCHITECTURE_ID,
        "scheduler_mode": EXPECTED_SCHEDULER_MODE,
        "logical_updates": snapshot_a["logical_updates"],
        "event_packet_count_per_update": len(EVENT_PACKET_PHASE_ORDER),
        "state_register_bits_per_lane": STATE_REGISTER_BITS_PER_LANE,
        "trace_sha256": sha256_hex(
            canonical_json_bytes(trace_a)
        ),
        "adapter_snapshot_sha256": snapshot_a[
            "adapter_snapshot_sha256"
        ],
        "binary_synchronous_contract_sha256": contract_a[
            "binary_synchronous_contract_sha256"
        ],
        "frp_kernel_imported": False,
        "winner_assertions": [],
    }

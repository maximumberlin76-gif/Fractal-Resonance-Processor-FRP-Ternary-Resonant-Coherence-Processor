#!/usr/bin/env python3
"""Common convergence contract for the FRP nonlinear multitask benchmark.

The first benchmark stage is hard-locked to ``scheduler_mode = free``. This
module derives convergence only from common balanced-ternary semantic states
and PHASE_U32 phase words. It does not import or duplicate the FRP kernel,
execute any architecture, apply thermal throttling, or produce rankings.
"""

from __future__ import annotations

import hashlib
import json
import math
from dataclasses import dataclass
from typing import Any, Mapping, NoReturn, Sequence

CONTRACT_SCHEMA = "frp.benchmark.nonlinear_multitask_convergence_contract.v1"
DOMAIN_SCHEMA = "frp.benchmark.nonlinear_multitask_domain_convergence.v1"
CASE_SCHEMA = "frp.benchmark.nonlinear_multitask_case_convergence.v1"
SEMANTIC_SCHEMA = "frp.benchmark.nonlinear_multitask_semantic_comparison.v1"

EXPECTED_SCHEDULER_MODE = "free"
TERNARY_STATES = (-1, 0, 1)
PHASE_U32_MOD = 1 << 32
PHASE_U32_HALF = 1 << 31

EXPECTED_CONVERGENCE_CONTRACT = {
    "state_stability_ticks": 8,
    "phase_velocity_dispersion_max_radians_per_tick": 0.01,
    "phase_coherence_delta_max": 0.001,
    "semantic_state_output": "exact_balanced_ternary_state_vector",
    "semantic_completion_ratio_required": 1.0,
    "semantic_output_match_required": 1.0,
    "maximum_logical_iterations_per_domain": 4096,
    "maximum_benchmark_ticks_per_case": 262144,
    "completion_requires_all_predicates": True,
}

EXPECTED_RANKING_ELIGIBILITY = {
    "require_semantic_completion_ratio": 1.0,
    "require_semantic_output_match": 1.0,
    "require_thermal_ceiling_status_not_equal": "ceiling_violation",
    "require_frp_invariants_for_frp": True,
}


class ConvergenceContractError(ValueError):
    """Raised when the shared convergence contract is violated."""


def fail(message: str) -> NoReturn:
    raise ConvergenceContractError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def canonical_json_bytes(value: Any) -> bytes:
    try:
        encoded = json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
            allow_nan=False,
        )
    except (TypeError, ValueError) as exc:
        fail(f"unable to canonicalize value: {exc}")

    return encoded.encode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require_int(
    value: Any,
    name: str,
    minimum: int = 0,
) -> int:
    require(
        not isinstance(value, bool)
        and isinstance(value, int),
        f"{name} must be an integer",
    )

    require(
        value >= minimum,
        f"{name} must be >= {minimum}",
    )

    return value


def require_finite(
    value: Any,
    name: str,
) -> float:
    require(
        not isinstance(value, bool)
        and isinstance(value, (int, float)),
        f"{name} must be numeric",
    )

    number = float(value)

    require(
        math.isfinite(number),
        f"{name} must be finite",
    )

    return number


def validate_states(
    states: Sequence[int],
    domain_size: int,
) -> tuple[int, ...]:
    require(
        not isinstance(states, (str, bytes)),
        "states must be a sequence",
    )

    result = tuple(states)

    require(
        len(result) == domain_size,
        "semantic state length mismatch",
    )

    require(
        all(
            not isinstance(state, bool)
            and isinstance(state, int)
            and state in TERNARY_STATES
            for state in result
        ),
        "semantic states must remain in {-1, 0, 1}",
    )

    return result


def validate_phase_words(
    phase_words: Sequence[int],
    domain_size: int,
) -> tuple[int, ...]:
    require(
        not isinstance(phase_words, (str, bytes)),
        "phase_words must be a sequence",
    )

    result = tuple(phase_words)

    require(
        len(result) == domain_size,
        "phase word length mismatch",
    )

    require(
        all(
            not isinstance(word, bool)
            and isinstance(word, int)
            and 0 <= word < PHASE_U32_MOD
            for word in result
        ),
        "phase words must remain unsigned 32-bit values",
    )

    return result


def phase_order_from_words(
    phase_words: Sequence[int],
) -> float:
    require(
        len(phase_words) > 0,
        "phase_words must not be empty",
    )

    real = 0.0
    imag = 0.0

    for word in phase_words:
        require(
            not isinstance(word, bool)
            and isinstance(word, int)
            and 0 <= word < PHASE_U32_MOD,
            "phase word must be an unsigned 32-bit value",
        )

        angle = (
            word
            / PHASE_U32_MOD
        ) * math.tau

        real += math.cos(angle)
        imag += math.sin(angle)

    count = len(phase_words)

    return math.hypot(
        real / count,
        imag / count,
    )


def signed_phase_delta_words(
    previous: int,
    current: int,
) -> int:
    for value, name in (
        (previous, "previous"),
        (current, "current"),
    ):
        require(
            not isinstance(value, bool)
            and isinstance(value, int)
            and 0 <= value < PHASE_U32_MOD,
            f"{name} phase word must be unsigned 32-bit",
        )

    delta = (
        current
        - previous
    ) % PHASE_U32_MOD

    if delta >= PHASE_U32_HALF:
        return delta - PHASE_U32_MOD

    return delta


def phase_velocity_dispersion(
    previous_phase_words: Sequence[int],
    current_phase_words: Sequence[int],
) -> float:
    require(
        len(previous_phase_words)
        == len(current_phase_words)
        > 0,
        "phase snapshot length mismatch",
    )

    scale = (
        math.tau
        / PHASE_U32_MOD
    )

    velocities = tuple(
        signed_phase_delta_words(
            previous,
            current,
        )
        * scale
        for previous, current
        in zip(
            previous_phase_words,
            current_phase_words,
        )
    )

    mean = (
        sum(velocities)
        / len(velocities)
    )

    return math.sqrt(
        sum(
            (
                velocity
                - mean
            )
            ** 2
            for velocity
            in velocities
        )
        / len(velocities)
    )


def semantic_output_digest(
    states: Sequence[int],
) -> str:
    normalized = validate_states(
        states,
        len(states),
    )

    return sha256_hex(
        canonical_json_bytes(
            list(normalized)
        )
    )


def validate_convergence_profile(
    profile: Mapping[str, Any],
) -> None:
    require(
        isinstance(profile, Mapping),
        "profile must be an object",
    )

    require(
        profile.get(
            "scheduler_mode"
        )
        == EXPECTED_SCHEDULER_MODE,
        "initial benchmark scheduler_mode must be free",
    )

    require(
        profile.get(
            "convergence_contract"
        )
        == EXPECTED_CONVERGENCE_CONTRACT,
        "convergence_contract mismatch",
    )

    require(
        profile.get(
            "ranking_eligibility_contract"
        )
        == EXPECTED_RANKING_ELIGIBILITY,
        "ranking_eligibility_contract mismatch",
    )

    validation = profile.get(
        "validation_contract"
    )

    require(
        isinstance(
            validation,
            Mapping,
        ),
        "validation_contract missing",
    )

    require(
        validation.get(
            "winner_assertions"
        )
        == [],
        "winner_assertions must be empty",
    )


@dataclass(frozen=True)
class ConvergenceThresholds:
    state_stability_ticks: int
    phase_velocity_dispersion_max_radians_per_tick: float
    phase_coherence_delta_max: float
    maximum_logical_iterations_per_domain: int
    maximum_benchmark_ticks_per_case: int

    @classmethod
    def from_profile(
        cls,
        profile: Mapping[str, Any],
    ) -> "ConvergenceThresholds":
        validate_convergence_profile(
            profile
        )

        contract = profile[
            "convergence_contract"
        ]

        return cls(
            state_stability_ticks=contract[
                "state_stability_ticks"
            ],
            phase_velocity_dispersion_max_radians_per_tick=contract[
                "phase_velocity_dispersion_max_radians_per_tick"
            ],
            phase_coherence_delta_max=contract[
                "phase_coherence_delta_max"
            ],
            maximum_logical_iterations_per_domain=contract[
                "maximum_logical_iterations_per_domain"
            ],
            maximum_benchmark_ticks_per_case=contract[
                "maximum_benchmark_ticks_per_case"
            ],
        )


@dataclass(frozen=True)
class DomainSnapshot:
    domain_index: int
    benchmark_tick: int
    logical_iteration: int
    state_stability_run_ticks: int
    phase_velocity_dispersion_radians_per_tick: float | None
    phase_coherence: float
    phase_coherence_delta: float | None
    state_stable: bool
    phase_velocity_converged: bool
    phase_coherence_converged: bool
    completed: bool
    time_to_solution_ticks: int | None
    semantic_output: tuple[int, ...] | None
    semantic_output_sha256: str | None

    def to_dict(
        self,
    ) -> dict[str, Any]:
        return {
            "schema": DOMAIN_SCHEMA,
            "domain_index": (
                self.domain_index
            ),
            "benchmark_tick": (
                self.benchmark_tick
            ),
            "logical_iteration": (
                self.logical_iteration
            ),
            "state_stability_run_ticks": (
                self.state_stability_run_ticks
            ),
            "phase_velocity_dispersion_radians_per_tick": (
                self.phase_velocity_dispersion_radians_per_tick
            ),
            "phase_coherence": (
                self.phase_coherence
            ),
            "phase_coherence_delta": (
                self.phase_coherence_delta
            ),
            "state_stable": (
                self.state_stable
            ),
            "phase_velocity_converged": (
                self.phase_velocity_converged
            ),
            "phase_coherence_converged": (
                self.phase_coherence_converged
            ),
            "completed": (
                self.completed
            ),
            "time_to_solution_ticks": (
                self.time_to_solution_ticks
            ),
            "semantic_output": (
                list(
                    self.semantic_output
                )
                if self.semantic_output
                is not None
                else None
            ),
            "semantic_output_sha256": (
                self.semantic_output_sha256
            ),
        }


class DomainConvergenceTracker:
    """Observe logical updates for one domain.

    Cooling ticks do not enter this tracker.
    """

    def __init__(
        self,
        *,
        domain_index: int,
        domain_size: int,
        thresholds: ConvergenceThresholds,
    ) -> None:
        self.domain_index = require_int(
            domain_index,
            "domain_index",
        )

        self.domain_size = require_int(
            domain_size,
            "domain_size",
            1,
        )

        self.thresholds = thresholds

        self._previous_benchmark_tick: (
            int
            | None
        ) = None

        self._previous_logical_iteration: (
            int
            | None
        ) = None

        self._previous_states: (
            tuple[int, ...]
            | None
        ) = None

        self._previous_phase_words: (
            tuple[int, ...]
            | None
        ) = None

        self._previous_coherence: (
            float
            | None
        ) = None

        self._stable_run = 0
        self._completed = False

        self._completion_tick: (
            int
            | None
        ) = None

        self._semantic_output: (
            tuple[int, ...]
            | None
        ) = None

        self._semantic_output_sha256: (
            str
            | None
        ) = None

    @property
    def completed(
        self,
    ) -> bool:
        return self._completed

    @property
    def semantic_output(
        self,
    ) -> tuple[int, ...] | None:
        return self._semantic_output

    def observe(
        self,
        *,
        benchmark_tick: int,
        logical_iteration: int,
        semantic_states: Sequence[int],
        phase_words: Sequence[int],
    ) -> DomainSnapshot:
        require(
            not self._completed,
            f"domain {self.domain_index} is already complete",
        )

        tick = require_int(
            benchmark_tick,
            "benchmark_tick",
        )

        logical = require_int(
            logical_iteration,
            "logical_iteration",
        )

        if (
            self._previous_benchmark_tick
            is not None
        ):
            require(
                tick
                > self._previous_benchmark_tick,
                "domain benchmark ticks must be strictly increasing",
            )

        if (
            self._previous_logical_iteration
            is None
        ):
            require(
                logical == 0,
                "first logical_iteration must be 0",
            )
        else:
            require(
                logical
                == self._previous_logical_iteration
                + 1,
                "domain logical iterations must be consecutive",
            )

        require(
            logical
            < self.thresholds.maximum_logical_iterations_per_domain,
            "maximum logical iterations per domain exceeded",
        )

        require(
            tick
            < self.thresholds.maximum_benchmark_ticks_per_case,
            "maximum benchmark ticks per case exceeded",
        )

        states = validate_states(
            semantic_states,
            self.domain_size,
        )

        phases = validate_phase_words(
            phase_words,
            self.domain_size,
        )

        coherence = phase_order_from_words(
            phases
        )

        if (
            self._previous_states
            is not None
            and states
            == self._previous_states
        ):
            self._stable_run += 1
        else:
            self._stable_run = 1

        state_stable = (
            self._stable_run
            >= self.thresholds.state_stability_ticks
        )

        if (
            self._previous_phase_words
            is None
        ):
            velocity_dispersion = None
            velocity_ok = False
        else:
            velocity_dispersion = (
                phase_velocity_dispersion(
                    self._previous_phase_words,
                    phases,
                )
            )

            velocity_ok = (
                velocity_dispersion
                <= self.thresholds.phase_velocity_dispersion_max_radians_per_tick
            )

        if (
            self._previous_coherence
            is None
        ):
            coherence_delta = None
            coherence_ok = False
        else:
            coherence_delta = abs(
                coherence
                - self._previous_coherence
            )

            coherence_ok = (
                coherence_delta
                <= self.thresholds.phase_coherence_delta_max
            )

        if (
            state_stable
            and velocity_ok
            and coherence_ok
        ):
            self._completed = True
            self._completion_tick = tick
            self._semantic_output = states

            self._semantic_output_sha256 = (
                semantic_output_digest(
                    states
                )
            )

        snapshot = DomainSnapshot(
            domain_index=(
                self.domain_index
            ),
            benchmark_tick=(
                tick
            ),
            logical_iteration=(
                logical
            ),
            state_stability_run_ticks=(
                self._stable_run
            ),
            phase_velocity_dispersion_radians_per_tick=(
                velocity_dispersion
            ),
            phase_coherence=(
                coherence
            ),
            phase_coherence_delta=(
                coherence_delta
            ),
            state_stable=(
                state_stable
            ),
            phase_velocity_converged=(
                velocity_ok
            ),
            phase_coherence_converged=(
                coherence_ok
            ),
            completed=(
                self._completed
            ),
            time_to_solution_ticks=(
                self._completion_tick
                + 1
                if self._completion_tick
                is not None
                else None
            ),
            semantic_output=(
                self._semantic_output
            ),
            semantic_output_sha256=(
                self._semantic_output_sha256
            ),
        )

        self._previous_benchmark_tick = (
            tick
        )

        self._previous_logical_iteration = (
            logical
        )

        self._previous_states = (
            states
        )

        self._previous_phase_words = (
            phases
        )

        self._previous_coherence = (
            coherence
        )

        return snapshot


class CaseConvergenceTracker:
    """Track all independent domains.

    Cooling ticks advance elapsed benchmark time but do
    not advance logical convergence observations.
    """

    def __init__(
        self,
        *,
        domain_size: int,
        concurrent_domain_count: int,
        thresholds: ConvergenceThresholds,
    ) -> None:
        self.domain_size = require_int(
            domain_size,
            "domain_size",
            1,
        )

        self.concurrent_domain_count = require_int(
            concurrent_domain_count,
            "concurrent_domain_count",
            1,
        )

        self._trackers = {
            index: DomainConvergenceTracker(
                domain_index=index,
                domain_size=(
                    self.domain_size
                ),
                thresholds=thresholds,
            )
            for index
            in range(
                self.concurrent_domain_count
            )
        }

        self._previous_tick: (
            int
            | None
        ) = None

        self._first_solution_tick: (
            int
            | None
        ) = None

        self._all_solutions_tick: (
            int
            | None
        ) = None

    @property
    def active_domain_indices(
        self,
    ) -> tuple[int, ...]:
        return tuple(
            index
            for index, tracker
            in self._trackers.items()
            if not tracker.completed
        )

    @property
    def completed_domain_indices(
        self,
    ) -> tuple[int, ...]:
        return tuple(
            index
            for index, tracker
            in self._trackers.items()
            if tracker.completed
        )

    @property
    def complete(
        self,
    ) -> bool:
        return (
            len(
                self.completed_domain_indices
            )
            == self.concurrent_domain_count
        )

    def observe_tick(
        self,
        *,
        benchmark_tick: int,
        domain_observations: Mapping[
            int,
            Mapping[str, Any],
        ],
    ) -> dict[int, DomainSnapshot]:
        require(
            not self.complete,
            "case is already complete",
        )

        tick = require_int(
            benchmark_tick,
            "benchmark_tick",
        )

        if (
            self._previous_tick
            is not None
        ):
            require(
                tick
                == self._previous_tick
                + 1,
                "benchmark ticks must be consecutive",
            )

        active = set(
            self.active_domain_indices
        )

        observed = set(
            domain_observations.keys()
        )

        require(
            observed.issubset(
                active
            ),
            "only active domains may be observed",
        )

        snapshots: dict[
            int,
            DomainSnapshot,
        ] = {}

        for domain_index in sorted(
            observed
        ):
            observation = (
                domain_observations[
                    domain_index
                ]
            )

            require(
                set(
                    observation.keys()
                )
                == {
                    "logical_iteration",
                    "semantic_states",
                    "phase_words",
                },
                "domain observation fields mismatch",
            )

            snapshot = (
                self._trackers[
                    domain_index
                ].observe(
                    benchmark_tick=tick,
                    logical_iteration=observation[
                        "logical_iteration"
                    ],
                    semantic_states=observation[
                        "semantic_states"
                    ],
                    phase_words=observation[
                        "phase_words"
                    ],
                )
            )

            snapshots[
                domain_index
            ] = snapshot

            if (
                snapshot.completed
                and self._first_solution_tick
                is None
            ):
                self._first_solution_tick = (
                    tick
                )

        if (
            self.complete
            and self._all_solutions_tick
            is None
        ):
            self._all_solutions_tick = (
                tick
            )

        self._previous_tick = (
            tick
        )

        return snapshots

    def semantic_outputs(
        self,
    ) -> tuple[
        tuple[int, ...],
        ...,
    ]:
        require(
            self.complete,
            "semantic outputs require a complete case",
        )

        outputs: list[
            tuple[int, ...]
        ] = []

        for index in range(
            self.concurrent_domain_count
        ):
            output = (
                self._trackers[
                    index
                ].semantic_output
            )

            require(
                output is not None,
                "completed domain output missing",
            )

            outputs.append(
                output
            )

        return tuple(
            outputs
        )

    def summary(
        self,
    ) -> dict[str, Any]:
        completed = len(
            self.completed_domain_indices
        )

        first_ticks = (
            self._first_solution_tick
            + 1
            if self._first_solution_tick
            is not None
            else None
        )

        all_ticks = (
            self._all_solutions_tick
            + 1
            if self._all_solutions_tick
            is not None
            else None
        )

        outputs = (
            self.semantic_outputs()
            if self.complete
            else None
        )

        payload: dict[
            str,
            Any,
        ] = {
            "schema": CASE_SCHEMA,
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "domain_size": (
                self.domain_size
            ),
            "concurrent_domain_count": (
                self.concurrent_domain_count
            ),
            "solutions_completed": (
                completed
            ),
            "semantic_completion_ratio": (
                completed
                / self.concurrent_domain_count
            ),
            "time_to_first_solution_ticks": (
                first_ticks
            ),
            "time_to_all_solutions_ticks": (
                all_ticks
            ),
            "steady_state_throughput": (
                self.concurrent_domain_count
                / all_ticks
                if all_ticks
                is not None
                else None
            ),
            "completed_domain_indices": list(
                self.completed_domain_indices
            ),
            "active_domain_indices": list(
                self.active_domain_indices
            ),
            "semantic_outputs": (
                [
                    list(output)
                    for output
                    in outputs
                ]
                if outputs
                is not None
                else None
            ),
        }

        payload[
            "case_convergence_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


def compare_semantic_outputs(
    reference_outputs: Sequence[
        Sequence[int]
    ],
    candidate_outputs: Sequence[
        Sequence[int]
    ],
) -> dict[str, Any]:
    reference = tuple(
        tuple(output)
        for output
        in reference_outputs
    )

    candidate = tuple(
        tuple(output)
        for output
        in candidate_outputs
    )

    require(
        len(reference) > 0,
        "reference outputs must not be empty",
    )

    require(
        len(reference)
        == len(candidate),
        "semantic output domain count mismatch",
    )

    matches: list[
        bool
    ] = []

    for index, (
        expected,
        actual,
    ) in enumerate(
        zip(
            reference,
            candidate,
        )
    ):
        require(
            len(expected)
            == len(actual)
            > 0,
            f"domain {index} output size mismatch",
        )

        validate_states(
            expected,
            len(expected),
        )

        validate_states(
            actual,
            len(expected),
        )

        matches.append(
            expected
            == actual
        )

    matched = sum(
        matches
    )

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            SEMANTIC_SCHEMA
        ),
        "domain_count": (
            len(reference)
        ),
        "matched_domains": (
            matched
        ),
        "semantic_output_match": (
            matched
            / len(reference)
        ),
        "exact_match": (
            all(matches)
        ),
        "match_vector": (
            matches
        ),
        "reference_output_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    [
                        list(output)
                        for output
                        in reference
                    ]
                )
            )
        ),
        "candidate_output_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    [
                        list(output)
                        for output
                        in candidate
                    ]
                )
            )
        ),
    }

    payload[
        "semantic_comparison_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    return payload


def ranking_eligibility(
    profile: Mapping[str, Any],
    *,
    semantic_completion_ratio: float,
    semantic_output_match: float,
    thermal_ceiling_status: str,
    frp_invariants_ok: bool | None,
    is_frp: bool,
) -> dict[str, Any]:
    """Apply the predeclared eligibility gate only.

    No ranking is produced here.
    """

    validate_convergence_profile(
        profile
    )

    completion = require_finite(
        semantic_completion_ratio,
        "semantic_completion_ratio",
    )

    output_match = require_finite(
        semantic_output_match,
        "semantic_output_match",
    )

    require(
        isinstance(
            thermal_ceiling_status,
            str,
        ),
        "thermal status must be a string",
    )

    require(
        isinstance(
            is_frp,
            bool,
        ),
        "is_frp must be boolean",
    )

    checks = {
        "semantic_completion_ratio": (
            completion
            == 1.0
        ),
        "semantic_output_match": (
            output_match
            == 1.0
        ),
        "thermal_ceiling_status": (
            thermal_ceiling_status
            != "ceiling_violation"
        ),
        "frp_invariants": (
            True
            if not is_frp
            else frp_invariants_ok
            is True
        ),
    }

    return {
        "eligible": all(
            checks.values()
        ),
        "checks": checks,
        "winner_assertions": [],
    }


def build_convergence_contract_summary(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    validate_convergence_profile(
        profile
    )

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            CONTRACT_SCHEMA
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "semantic_state_domain": list(
            TERNARY_STATES
        ),
        "phase_domain": (
            "PHASE_U32"
        ),
        "phase_velocity_derivation": (
            "shortest_signed_wrapped_delta_between_adjacent_phase_words"
        ),
        "phase_velocity_dispersion": (
            "population_rms_dispersion_around_arithmetic_mean"
        ),
        "phase_coherence": (
            "kuramoto_order_parameter_magnitude"
        ),
        "state_stability_counting": (
            "logical_update_observations_only"
        ),
        "cooling_tick_rule": (
            "cooling benchmark ticks advance elapsed time but do not advance "
            "logical iterations or convergence predicates"
        ),
        "time_to_solution_ticks": (
            "completion_benchmark_tick_zero_based_plus_one"
        ),
        "convergence_contract": (
            EXPECTED_CONVERGENCE_CONTRACT
        ),
        "ranking_eligibility_contract": (
            EXPECTED_RANKING_ELIGIBILITY
        ),
        "winner_assertions": [],
    }

    payload[
        "convergence_contract_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    return payload


def run_self_test(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    thresholds = (
        ConvergenceThresholds.from_profile(
            profile
        )
    )

    tracker = (
        CaseConvergenceTracker(
            domain_size=8,
            concurrent_domain_count=2,
            thresholds=thresholds,
        )
    )

    offsets = tuple(
        index
        * (
            PHASE_U32_MOD
            // 8
        )
        for index
        in range(8)
    )

    states = (
        -1,
        0,
        1,
        -1,
        0,
        1,
        -1,
        0,
    )

    logical_iterations = {
        0: 0,
        1: 0,
    }

    for tick in range(15):
        observations: dict[
            int,
            Mapping[str, Any],
        ] = {}

        if tick % 2 == 0:
            for domain_index in (
                tracker.active_domain_indices
            ):
                logical = (
                    logical_iterations[
                        domain_index
                    ]
                )

                phases = tuple(
                    (
                        offset
                        + domain_index
                        * (
                            1
                            << 24
                        )
                        + logical
                        * (
                            1
                            << 20
                        )
                    )
                    % PHASE_U32_MOD
                    for offset
                    in offsets
                )

                observations[
                    domain_index
                ] = {
                    "logical_iteration": (
                        logical
                    ),
                    "semantic_states": (
                        states
                    ),
                    "phase_words": (
                        phases
                    ),
                }

                logical_iterations[
                    domain_index
                ] += 1

        tracker.observe_tick(
            benchmark_tick=tick,
            domain_observations=(
                observations
            ),
        )

    require(
        tracker.complete,
        "self-test case did not converge",
    )

    summary = tracker.summary()

    require(
        summary[
            "time_to_first_solution_ticks"
        ]
        == 15,
        "self-test first latency mismatch",
    )

    require(
        summary[
            "time_to_all_solutions_ticks"
        ]
        == 15,
        "self-test all latency mismatch",
    )

    require(
        summary[
            "semantic_completion_ratio"
        ]
        == 1.0,
        "self-test completion mismatch",
    )

    outputs = tracker.semantic_outputs()

    comparison = compare_semantic_outputs(
        outputs,
        outputs,
    )

    require(
        comparison[
            "semantic_output_match"
        ]
        == 1.0,
        "self-test semantic match failed",
    )

    eligible = ranking_eligibility(
        profile,
        semantic_completion_ratio=1.0,
        semantic_output_match=1.0,
        thermal_ceiling_status=(
            "within_ceiling"
        ),
        frp_invariants_ok=True,
        is_frp=True,
    )

    require(
        eligible[
            "eligible"
        ]
        is True,
        "self-test eligibility failed",
    )

    blocked = ranking_eligibility(
        profile,
        semantic_completion_ratio=1.0,
        semantic_output_match=1.0,
        thermal_ceiling_status=(
            "ceiling_violation"
        ),
        frp_invariants_ok=True,
        is_frp=True,
    )

    require(
        blocked[
            "eligible"
        ]
        is False,
        "ceiling violation must block ranking",
    )

    first_contract = (
        build_convergence_contract_summary(
            profile
        )
    )

    second_contract = (
        build_convergence_contract_summary(
            profile
        )
    )

    require(
        first_contract
        == second_contract,
        "contract summary is not deterministic",
    )

    return {
        "status": "PASS",
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "case_convergence_sha256": (
            summary[
                "case_convergence_sha256"
            ]
        ),
        "semantic_comparison_sha256": (
            comparison[
                "semantic_comparison_sha256"
            ]
        ),
        "convergence_contract_sha256": (
            first_contract[
                "convergence_contract_sha256"
            ]
        ),
        "cooling_ticks_advance_convergence": (
            False
        ),
        "winner_assertions": [],
    }

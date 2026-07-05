#!/usr/bin/env python3
"""Shared nonlinear coupled-state problem for the FRP multitask benchmark.

The first benchmark stage is hard-locked to ``scheduler_mode = free``. This
module materializes one architecture-neutral hierarchical Kuramoto-Sakaguchi
problem from the predeclared workload profile. It does not import or duplicate
the FRP kernel, assign architecture costs, apply the common thermal ceiling, or
produce rankings.
"""

from __future__ import annotations

import hashlib
import json
import math
from dataclasses import dataclass, replace
from functools import lru_cache
from typing import Any, Mapping, NoReturn, Sequence

PROBLEM_SCHEMA = "frp.benchmark.nonlinear_multitask_problem.v1"
STATE_SCHEMA = "frp.benchmark.nonlinear_multitask_problem_state.v1"
STEP_SCHEMA = "frp.benchmark.nonlinear_multitask_problem_step.v1"
CONTRACT_SCHEMA = "frp.benchmark.nonlinear_multitask_problem_contract.v1"
SELF_TEST_SCHEMA = "frp.benchmark.nonlinear_multitask_problem.self_test.v1"

EXPECTED_SCHEDULER_MODE = "free"
EXPECTED_MODEL_NAME = "hierarchical_kuramoto_sakaguchi_phase_convergence_v1"
EXPECTED_PHASE_DOMAIN = "PHASE_U32"
EXPECTED_TOPOLOGY = "deterministic_dyadic_hierarchical_v1"
EXPECTED_STATE_DOMAIN = (-1, 0, 1)

PHASE_MOD = 1 << 32
PHASE_MASK = PHASE_MOD - 1
PHASE_HALF = 1 << 31
Q16_SCALE = 1 << 16
STATE_THRESHOLD = 0.33

EXPECTED_SHARED_PROBLEM_MODEL = {
    "name": EXPECTED_MODEL_NAME,
    "phase_domain": EXPECTED_PHASE_DOMAIN,
    "balanced_ternary_state_domain": [-1, 0, 1],
    "topology": EXPECTED_TOPOLOGY,
    "fractal_alpha": 0.7,
    "thermal_beta": 1.2,
    "ambient_heat": 0.05,
    "thermal_time_constant": 14.0,
    "thermal_soft_limit": 0.22,
    "thermal_hard_limit": 0.9,
    "thermal_diffusion_gain": 0.035,
    "base_frequency": 1.0,
    "phase_velocity_base_gain": 0.06,
    "scheduler_push_free": 0.003,
    "state_projection_rule": {
        "positive": "sin(phase) > 0.33",
        "neutral": "-0.33 <= sin(phase) <= 0.33",
        "negative": "sin(phase) < -0.33",
    },
    "cross_domain_coupling_gain": 0.0,
    "domain_independence": True,
}

EXPECTED_NONLINEARITY_CLASSES = {
    "low": {
        "class_index": 0,
        "coupling_nominal": 0.14,
        "gamma_nominal_ratio_pi": 0.15,
        "gamma_nominal_radians": 0.471238898038469,
        "delay_alpha": 0.15,
        "gamma_noise_target_scale": 0.025,
        "parameter_rule": (
            "0.5x M15 nominal coupling, gamma, and delay; "
            "0.5x medium gamma-noise scale"
        ),
    },
    "medium": {
        "class_index": 1,
        "coupling_nominal": 0.28,
        "gamma_nominal_ratio_pi": 0.3,
        "gamma_nominal_radians": 0.942477796076938,
        "delay_alpha": 0.3,
        "gamma_noise_target_scale": 0.05,
        "parameter_rule": "M15 nominal coupling, gamma, and delay",
    },
    "high": {
        "class_index": 2,
        "coupling_nominal": 0.42,
        "gamma_nominal_ratio_pi": 0.45,
        "gamma_nominal_radians": 1.413716694115407,
        "delay_alpha": 0.45,
        "gamma_noise_target_scale": 0.1,
        "parameter_rule": (
            "1.5x M15 nominal coupling, gamma, and delay; "
            "2.0x medium gamma-noise scale"
        ),
    },
}


class NonlinearProblemError(ValueError):
    """Raised when the shared nonlinear problem contract is violated."""


def fail(message: str) -> NoReturn:
    raise NonlinearProblemError(message)


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


def require_int(value: Any, name: str, minimum: int | None = None) -> int:
    require(
        not isinstance(value, bool) and isinstance(value, int),
        f"{name} must be an integer",
    )

    if minimum is not None:
        require(value >= minimum, f"{name} must be >= {minimum}")

    return value


def require_finite(value: Any, name: str) -> float:
    require(
        not isinstance(value, bool) and isinstance(value, (int, float)),
        f"{name} must be numeric",
    )

    number = float(value)

    require(
        math.isfinite(number),
        f"{name} must be finite",
    )

    return number


def q16(value: float) -> int:
    number = require_finite(
        value,
        "q16 value",
    )

    scaled = (
        number
        * Q16_SCALE
    )

    if scaled >= 0.0:
        return int(
            math.floor(
                scaled
                + 0.5
            )
        )

    return -int(
        math.floor(
            -scaled
            + 0.5
        )
    )


def q16_to_float(value: int) -> float:
    require_int(
        value,
        "q16 encoded value",
    )

    return (
        value
        / Q16_SCALE
    )


def round_half_away_from_zero(value: float) -> int:
    number = require_finite(
        value,
        "rounding value",
    )

    if number >= 0.0:
        return int(
            math.floor(
                number
                + 0.5
            )
        )

    return -int(
        math.floor(
            -number
            + 0.5
        )
    )


def phase_word_to_radians(
    phase_word: int,
) -> float:
    require(
        not isinstance(
            phase_word,
            bool,
        )
        and isinstance(
            phase_word,
            int,
        )
        and 0
        <= phase_word
        < PHASE_MOD,
        "phase_word must be an unsigned 32-bit value",
    )

    return (
        phase_word
        / PHASE_MOD
    ) * math.tau


def radians_to_phase_delta_word(
    radians: float,
) -> int:
    number = require_finite(
        radians,
        "phase delta radians",
    )

    return round_half_away_from_zero(
        (
            number
            / math.tau
        )
        * PHASE_MOD
    )


def signed_phase_delta_words(
    previous: int,
    current: int,
) -> int:
    for value, name in (
        (
            previous,
            "previous",
        ),
        (
            current,
            "current",
        ),
    ):
        require(
            not isinstance(
                value,
                bool,
            )
            and isinstance(
                value,
                int,
            )
            and 0
            <= value
            < PHASE_MOD,
            f"{name} phase word must be unsigned 32-bit",
        )

    delta = (
        current
        - previous
    ) & PHASE_MASK

    if delta >= PHASE_HALF:
        delta -= PHASE_MOD

    return delta


def project_state_from_phase_word(
    phase_word: int,
) -> int:
    sine = math.sin(
        phase_word_to_radians(
            phase_word
        )
    )

    if sine > STATE_THRESHOLD:
        return 1

    if sine < -STATE_THRESHOLD:
        return -1

    return 0


def validate_problem_profile(
    profile: Mapping[
        str,
        Any,
    ],
) -> None:
    require(
        isinstance(
            profile,
            Mapping,
        ),
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
            "shared_problem_model"
        )
        == EXPECTED_SHARED_PROBLEM_MODEL,
        "shared_problem_model mismatch",
    )

    require(
        profile.get(
            "nonlinearity_classes"
        )
        == EXPECTED_NONLINEARITY_CLASSES,
        "nonlinearity_classes mismatch",
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

    fairness = profile.get(
        "resource_fairness_contract"
    )

    require(
        isinstance(
            fairness,
            Mapping,
        ),
        "resource_fairness_contract missing",
    )

    require(
        fairness.get(
            "domain_execution_order"
        )
        == "domain_index_ascending_round_robin",
        "domain execution order mismatch",
    )

    require(
        fairness.get(
            "hidden_parallelism"
        )
        is False,
        "hidden_parallelism must be false",
    )


def hierarchy_depth(
    domain_size: int,
) -> int:
    size = require_int(
        domain_size,
        "domain_size",
        2,
    )

    require(
        size
        & (
            size
            - 1
        )
        == 0,
        "domain_size must be a power of two",
    )

    return (
        size.bit_length()
        - 1
    )


def hierarchical_distance(
    left: int,
    right: int,
) -> int:
    require_int(
        left,
        "left index",
        0,
    )

    require_int(
        right,
        "right index",
        0,
    )

    if left == right:
        return 0

    return (
        left
        ^ right
    ).bit_length()


def shell_population(
    distance: int,
) -> int:
    value = require_int(
        distance,
        "distance",
        1,
    )

    return (
        1
        << (
            value
            - 1
        )
    )


@lru_cache(
    maxsize=None
)
def hierarchical_pair_weights(
    domain_size: int,
    exponent: float,
) -> tuple[
    tuple[
        float,
        ...,
    ],
    ...,
]:
    size = require_int(
        domain_size,
        "domain_size",
        2,
    )

    depth = hierarchy_depth(
        size
    )

    power = require_finite(
        exponent,
        "topology exponent",
    )

    require(
        power > 0.0,
        "topology exponent must be greater than zero",
    )

    normalizer = math.fsum(
        1.0
        / (
            distance
            ** power
        )
        for distance
        in range(
            1,
            depth
            + 1,
        )
    )

    level_weights = {
        distance: (
            1.0
            / (
                shell_population(
                    distance
                )
                * (
                    distance
                    ** power
                )
                * normalizer
            )
        )
        for distance
        in range(
            1,
            depth
            + 1,
        )
    }

    matrix: list[
        tuple[
            float,
            ...,
        ]
    ] = []

    for left in range(
        size
    ):
        row = []

        for right in range(
            size
        ):
            if left == right:
                row.append(
                    0.0
                )

            else:
                row.append(
                    level_weights[
                        hierarchical_distance(
                            left,
                            right,
                        )
                    ]
                )

        matrix.append(
            tuple(
                row
            )
        )

    result = tuple(
        matrix
    )

    for index, row in enumerate(
        result
    ):
        require(
            math.isclose(
                math.fsum(
                    row
                ),
                1.0,
                rel_tol=0.0,
                abs_tol=1e-12,
            ),
            f"topology row {index} does not sum to 1.0",
        )

        require(
            row[
                index
            ]
            == 0.0,
            "topology diagonal must be zero",
        )

        for other in range(
            size
        ):
            require(
                math.isclose(
                    row[
                        other
                    ],
                    result[
                        other
                    ][
                        index
                    ],
                    rel_tol=0.0,
                    abs_tol=1e-15,
                ),
                "topology matrix must be symmetric",
            )

    return result


def thermal_node_factor(
    heat: float,
    soft_limit: float,
    hard_limit: float,
) -> float:
    temperature = require_finite(
        heat,
        "heat",
    )

    soft = require_finite(
        soft_limit,
        "thermal_soft_limit",
    )

    hard = require_finite(
        hard_limit,
        "thermal_hard_limit",
    )

    require(
        hard > soft,
        "thermal_hard_limit must exceed thermal_soft_limit",
    )

    if temperature <= soft:
        return 1.0

    if temperature >= hard:
        return 0.0

    return (
        hard
        - temperature
    ) / (
        hard
        - soft
    )


@dataclass(
    frozen=True
)
class ProblemParameters:
    nonlinearity_class: str

    coupling_nominal: float

    gamma_nominal_radians: float

    delay_alpha: float

    gamma_noise_target_scale: float

    fractal_alpha: float

    thermal_beta: float

    ambient_heat: float

    thermal_time_constant: float

    thermal_soft_limit: float

    thermal_hard_limit: float

    thermal_diffusion_gain: float

    base_frequency: float

    phase_velocity_base_gain: float

    scheduler_push_free: float

    @classmethod
    def from_profile(
        cls,
        profile: Mapping[
            str,
            Any,
        ],
        nonlinearity_class: str,
    ) -> "ProblemParameters":
        validate_problem_profile(
            profile
        )

        require(
            nonlinearity_class
            in EXPECTED_NONLINEARITY_CLASSES,
            "invalid nonlinearity_class",
        )

        shared = profile[
            "shared_problem_model"
        ]

        selected = profile[
            "nonlinearity_classes"
        ][
            nonlinearity_class
        ]

        return cls(
            nonlinearity_class=(
                nonlinearity_class
            ),
            coupling_nominal=float(
                selected[
                    "coupling_nominal"
                ]
            ),
            gamma_nominal_radians=float(
                selected[
                    "gamma_nominal_radians"
                ]
            ),
            delay_alpha=float(
                selected[
                    "delay_alpha"
                ]
            ),
            gamma_noise_target_scale=float(
                selected[
                    "gamma_noise_target_scale"
                ]
            ),
            fractal_alpha=float(
                shared[
                    "fractal_alpha"
                ]
            ),
            thermal_beta=float(
                shared[
                    "thermal_beta"
                ]
            ),
            ambient_heat=float(
                shared[
                    "ambient_heat"
                ]
            ),
            thermal_time_constant=float(
                shared[
                    "thermal_time_constant"
                ]
            ),
            thermal_soft_limit=float(
                shared[
                    "thermal_soft_limit"
                ]
            ),
            thermal_hard_limit=float(
                shared[
                    "thermal_hard_limit"
                ]
            ),
            thermal_diffusion_gain=float(
                shared[
                    "thermal_diffusion_gain"
                ]
            ),
            base_frequency=float(
                shared[
                    "base_frequency"
                ]
            ),
            phase_velocity_base_gain=float(
                shared[
                    "phase_velocity_base_gain"
                ]
            ),
            scheduler_push_free=float(
                shared[
                    "scheduler_push_free"
                ]
            ),
        )

    def to_dict(
        self,
    ) -> dict[
        str,
        Any,
    ]:
        return {
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "coupling_nominal": (
                self.coupling_nominal
            ),
            "gamma_nominal_radians": (
                self.gamma_nominal_radians
            ),
            "delay_alpha": (
                self.delay_alpha
            ),
            "gamma_noise_target_scale": (
                self.gamma_noise_target_scale
            ),
            "fractal_alpha": (
                self.fractal_alpha
            ),
            "thermal_beta": (
                self.thermal_beta
            ),
            "ambient_heat": (
                self.ambient_heat
            ),
            "thermal_time_constant": (
                self.thermal_time_constant
            ),
            "thermal_soft_limit": (
                self.thermal_soft_limit
            ),
            "thermal_hard_limit": (
                self.thermal_hard_limit
            ),
            "thermal_diffusion_gain": (
                self.thermal_diffusion_gain
            ),
            "base_frequency": (
                self.base_frequency
            ),
            "phase_velocity_base_gain": (
                self.phase_velocity_base_gain
            ),
            "scheduler_push_free": (
                self.scheduler_push_free
            ),
        }


@dataclass(
    frozen=True
)
class ProblemDomainState:
    domain_size: int

    domain_index: int

    nonlinearity_class: str

    logical_iteration: int

    semantic_states: tuple[
        int,
        ...,
    ]

    phase_words: tuple[
        int,
        ...,
    ]

    frequency_target_q16: tuple[
        int,
        ...,
    ]

    frequency_current_q16: tuple[
        int,
        ...,
    ]

    heat_q16: tuple[
        int,
        ...,
    ]

    delayed_coupling_q16: tuple[
        int,
        ...,
    ]

    def to_dict(
        self,
    ) -> dict[
        str,
        Any,
    ]:
        payload = {
            "schema": (
                STATE_SCHEMA
            ),
            "domain_size": (
                self.domain_size
            ),
            "domain_index": (
                self.domain_index
            ),
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "logical_iteration": (
                self.logical_iteration
            ),
            "semantic_states": list(
                self.semantic_states
            ),
            "phase_words": list(
                self.phase_words
            ),
            "frequency_target_q16": list(
                self.frequency_target_q16
            ),
            "frequency_current_q16": list(
                self.frequency_current_q16
            ),
            "heat_q16": list(
                self.heat_q16
            ),
            "delayed_coupling_q16": list(
                self.delayed_coupling_q16
            ),
        }

        payload[
            "problem_state_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


@dataclass(
    frozen=True
)
class ProblemStepResult:
    state: ProblemDomainState

    gamma_targets_q16: tuple[
        int,
        ...,
    ]

    gamma_effective_radians: tuple[
        float,
        ...,
    ]

    thermal_node_factors: tuple[
        float,
        ...,
    ]

    instantaneous_coupling: tuple[
        float,
        ...,
    ]

    delayed_coupling: tuple[
        float,
        ...,
    ]

    phase_velocity_radians_per_tick: tuple[
        float,
        ...,
    ]

    generated_heat: tuple[
        float,
        ...,
    ]

    thermal_dissipation: tuple[
        float,
        ...,
    ]

    thermal_diffusion: tuple[
        float,
        ...,
    ]

    state_change_count: int

    def to_dict(
        self,
    ) -> dict[
        str,
        Any,
    ]:
        payload = {
            "schema": (
                STEP_SCHEMA
            ),
            "logical_iteration": (
                self.state.logical_iteration
            ),
            "domain_size": (
                self.state.domain_size
            ),
            "domain_index": (
                self.state.domain_index
            ),
            "nonlinearity_class": (
                self.state.nonlinearity_class
            ),
            "gamma_targets_q16": list(
                self.gamma_targets_q16
            ),
            "gamma_effective_radians": list(
                self.gamma_effective_radians
            ),
            "thermal_node_factors": list(
                self.thermal_node_factors
            ),
            "instantaneous_coupling": list(
                self.instantaneous_coupling
            ),
            "delayed_coupling": list(
                self.delayed_coupling
            ),
            "phase_velocity_radians_per_tick": list(
                self.phase_velocity_radians_per_tick
            ),
            "generated_heat": list(
                self.generated_heat
            ),
            "thermal_dissipation": list(
                self.thermal_dissipation
            ),
            "thermal_diffusion": list(
                self.thermal_diffusion
            ),
            "state_change_count": (
                self.state_change_count
            ),
            "semantic_states": list(
                self.state.semantic_states
            ),
            "phase_words": list(
                self.state.phase_words
            ),
            "frequency_target_q16": list(
                self.state.frequency_target_q16
            ),
            "frequency_current_q16": list(
                self.state.frequency_current_q16
            ),
            "heat_q16": list(
                self.state.heat_q16
            ),
            "delayed_coupling_q16": list(
                self.state.delayed_coupling_q16
            ),
        }

        payload[
            "problem_step_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


def validate_problem_state(
    state: ProblemDomainState,
) -> None:
    size = hierarchy_depth(
        state.domain_size
    )

    require(
        size >= 1,
        "invalid hierarchy depth",
    )

    require_int(
        state.domain_index,
        "domain_index",
        0,
    )

    require_int(
        state.logical_iteration,
        "logical_iteration",
        0,
    )

    require(
        state.nonlinearity_class
        in EXPECTED_NONLINEARITY_CLASSES,
        "invalid nonlinearity_class",
    )

    vectors: tuple[
        Sequence[
            Any
        ],
        ...,
    ] = (
        state.semantic_states,
        state.phase_words,
        state.frequency_target_q16,
        state.frequency_current_q16,
        state.heat_q16,
        state.delayed_coupling_q16,
    )

    require(
        all(
            len(
                vector
            )
            == state.domain_size
            for vector
            in vectors
        ),
        "problem state vector length mismatch",
    )

    require(
        all(
            value
            in EXPECTED_STATE_DOMAIN
            for value
            in state.semantic_states
        ),
        "semantic_states contain an invalid value",
    )

    require(
        all(
            not isinstance(
                value,
                bool,
            )
            and isinstance(
                value,
                int,
            )
            and 0
            <= value
            < PHASE_MOD
            for value
            in state.phase_words
        ),
        "phase_words contain an invalid value",
    )

    require(
        all(
            not isinstance(
                value,
                bool,
            )
            and isinstance(
                value,
                int,
            )
            for vector
            in vectors[
                2:
            ]
            for value
            in vector
        ),
        "Q16 problem vectors must contain integers",
    )


def build_problem_state(
    initialization: Any,
) -> ProblemDomainState:
    required_attributes = (
        "domain_size",
        "domain_index",
        "nonlinearity_class",
        "initial_states",
        "initial_phase_words",
        "initial_frequency_target_q16",
        "initial_frequency_current_q16",
        "initial_heat_q16",
    )

    for attribute in required_attributes:
        require(
            hasattr(
                initialization,
                attribute,
            ),
            f"initialization missing attribute: {attribute}",
        )

    domain_size = require_int(
        initialization.domain_size,
        "domain_size",
        2,
    )

    hierarchy_depth(
        domain_size
    )

    state = ProblemDomainState(
        domain_size=(
            domain_size
        ),
        domain_index=require_int(
            initialization.domain_index,
            "domain_index",
            0,
        ),
        nonlinearity_class=str(
            initialization.nonlinearity_class
        ),
        logical_iteration=0,
        semantic_states=tuple(
            int(
                value
            )
            for value
            in initialization.initial_states
        ),
        phase_words=tuple(
            int(
                value
            )
            for value
            in initialization.initial_phase_words
        ),
        frequency_target_q16=tuple(
            int(
                value
            )
            for value
            in initialization.initial_frequency_target_q16
        ),
        frequency_current_q16=tuple(
            int(
                value
            )
            for value
            in initialization.initial_frequency_current_q16
        ),
        heat_q16=tuple(
            int(
                value
            )
            for value
            in initialization.initial_heat_q16
        ),
        delayed_coupling_q16=tuple(
            0
            for _ in range(
                domain_size
            )
        ),
    )

    validate_problem_state(
        state
    )

    return state


def _validate_gamma_targets(
    gamma_targets_q16: Sequence[
        int
    ],
    domain_size: int,
    parameters: ProblemParameters,
) -> tuple[
    int,
    ...,
]:
    require(
        not isinstance(
            gamma_targets_q16,
            (
                str,
                bytes,
                bytearray,
            ),
        ),
        "gamma_targets_q16 must be a sequence",
    )

    targets = tuple(
        gamma_targets_q16
    )

    require(
        len(
            targets
        )
        == domain_size,
        "gamma target vector length mismatch",
    )

    require(
        all(
            not isinstance(
                value,
                bool,
            )
            and isinstance(
                value,
                int,
            )
            for value
            in targets
        ),
        "gamma targets must be integer Q16 values",
    )

    scale_q16 = q16(
        parameters.gamma_noise_target_scale
    )

    require(
        all(
            -scale_q16
            <= value
            <= scale_q16
            for value
            in targets
        ),
        "gamma target exceeds the predeclared class scale",
    )

    return targets


def problem_operation_shape(
    domain_size: int,
) -> dict[
    str,
    int,
]:
    size = require_int(
        domain_size,
        "domain_size",
        2,
    )

    hierarchy_depth(
        size
    )

    pair_interactions = (
        size
        * (
            size
            - 1
        )
    )

    return {
        "state_lanes": (
            size
        ),
        "phase_lanes": (
            size
        ),
        "frequency_lanes": (
            size
        ),
        "thermal_lanes": (
            size
        ),
        "phase_pair_interactions": (
            pair_interactions
        ),
        "thermal_pair_interactions": (
            pair_interactions
        ),
        "state_projections": (
            size
        ),
    }


def step_problem_domain(
    profile: Mapping[
        str,
        Any,
    ],
    state: ProblemDomainState,
    *,
    gamma_targets_q16: Sequence[
        int
    ],
) -> ProblemStepResult:
    """Advance one architecture-neutral logical problem iteration."""

    validate_problem_profile(
        profile
    )

    validate_problem_state(
        state
    )

    parameters = (
        ProblemParameters.from_profile(
            profile,
            state.nonlinearity_class,
        )
    )

    targets = (
        _validate_gamma_targets(
            gamma_targets_q16,
            state.domain_size,
            parameters,
        )
    )

    phase_weights = (
        hierarchical_pair_weights(
            state.domain_size,
            parameters.fractal_alpha,
        )
    )

    thermal_weights = (
        hierarchical_pair_weights(
            state.domain_size,
            parameters.thermal_beta,
        )
    )

    phases = tuple(
        phase_word_to_radians(
            word
        )
        for word
        in state.phase_words
    )

    heat = tuple(
        q16_to_float(
            value
        )
        for value
        in state.heat_q16
    )

    current_frequency = tuple(
        q16_to_float(
            value
        )
        for value
        in state.frequency_current_q16
    )

    previous_delayed_coupling = tuple(
        q16_to_float(
            value
        )
        for value
        in state.delayed_coupling_q16
    )

    node_factors = tuple(
        thermal_node_factor(
            value,
            parameters.thermal_soft_limit,
            parameters.thermal_hard_limit,
        )
        for value
        in heat
    )

    gamma_effective = tuple(
        parameters.gamma_nominal_radians
        + q16_to_float(
            target
        )
        for target
        in targets
    )

    instantaneous: list[
        float
    ] = []

    for cell_index in range(
        state.domain_size
    ):
        total = math.fsum(
            phase_weights[
                cell_index
            ][
                other
            ]
            * node_factors[
                cell_index
            ]
            * node_factors[
                other
            ]
            * math.sin(
                phases[
                    other
                ]
                - phases[
                    cell_index
                ]
                - gamma_effective[
                    cell_index
                ]
            )
            for other
            in range(
                state.domain_size
            )
            if other
            != cell_index
        )

        instantaneous.append(
            parameters.coupling_nominal
            * total
        )

    delayed = tuple(
        previous_delayed_coupling[
            index
        ]
        + parameters.delay_alpha
        * (
            instantaneous[
                index
            ]
            - previous_delayed_coupling[
                index
            ]
        )
        for index
        in range(
            state.domain_size
        )
    )

    frequency_target = tuple(
        parameters.base_frequency
        + abs(
            value
        )
        for value
        in delayed
    )

    frequency_current = tuple(
        current_frequency[
            index
        ]
        + parameters.delay_alpha
        * (
            frequency_target[
                index
            ]
            - current_frequency[
                index
            ]
        )
        for index
        in range(
            state.domain_size
        )
    )

    phase_velocity = tuple(
        parameters.phase_velocity_base_gain
        * frequency_current[
            index
        ]
        + parameters.scheduler_push_free
        + delayed[
            index
        ]
        for index
        in range(
            state.domain_size
        )
    )

    generated_heat = tuple(
        value
        * value
        for value
        in phase_velocity
    )

    thermal_dissipation = tuple(
        (
            value
            - parameters.ambient_heat
        )
        / parameters.thermal_time_constant
        for value
        in heat
    )

    thermal_diffusion = tuple(
        parameters.thermal_diffusion_gain
        * math.fsum(
            thermal_weights[
                cell_index
            ][
                other
            ]
            * (
                heat[
                    other
                ]
                - heat[
                    cell_index
                ]
            )
            for other
            in range(
                state.domain_size
            )
            if other
            != cell_index
        )
        for cell_index
        in range(
            state.domain_size
        )
    )

    next_heat = tuple(
        max(
            parameters.ambient_heat,
            heat[
                index
            ]
            + generated_heat[
                index
            ]
            - thermal_dissipation[
                index
            ]
            + thermal_diffusion[
                index
            ],
        )
        for index
        in range(
            state.domain_size
        )
    )

    next_phase_words = tuple(
        (
            state.phase_words[
                index
            ]
            + radians_to_phase_delta_word(
                phase_velocity[
                    index
                ]
            )
        )
        & PHASE_MASK
        for index
        in range(
            state.domain_size
        )
    )

    next_states = tuple(
        project_state_from_phase_word(
            word
        )
        for word
        in next_phase_words
    )

    state_change_count = sum(
        1
        for before, after
        in zip(
            state.semantic_states,
            next_states,
        )
        if before
        != after
    )

    next_state = replace(
        state,
        logical_iteration=(
            state.logical_iteration
            + 1
        ),
        semantic_states=(
            next_states
        ),
        phase_words=(
            next_phase_words
        ),
        frequency_target_q16=tuple(
            q16(
                value
            )
            for value
            in frequency_target
        ),
        frequency_current_q16=tuple(
            q16(
                value
            )
            for value
            in frequency_current
        ),
        heat_q16=tuple(
            q16(
                value
            )
            for value
            in next_heat
        ),
        delayed_coupling_q16=tuple(
            q16(
                value
            )
            for value
            in delayed
        ),
    )

    validate_problem_state(
        next_state
    )

    return ProblemStepResult(
        state=(
            next_state
        ),
        gamma_targets_q16=(
            targets
        ),
        gamma_effective_radians=(
            gamma_effective
        ),
        thermal_node_factors=(
            node_factors
        ),
        instantaneous_coupling=tuple(
            instantaneous
        ),
        delayed_coupling=(
            delayed
        ),
        phase_velocity_radians_per_tick=(
            phase_velocity
        ),
        generated_heat=(
            generated_heat
        ),
        thermal_dissipation=(
            thermal_dissipation
        ),
        thermal_diffusion=(
            thermal_diffusion
        ),
        state_change_count=(
            state_change_count
        ),
    )


def build_problem_contract_summary(
    profile: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
]:
    validate_problem_profile(
        profile
    )

    payload: dict[
        str,
        Any,
    ] = {
        "schema": (
            CONTRACT_SCHEMA
        ),
        "problem_schema": (
            PROBLEM_SCHEMA
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "model_name": (
            EXPECTED_MODEL_NAME
        ),
        "phase_domain": (
            EXPECTED_PHASE_DOMAIN
        ),
        "semantic_state_domain": list(
            EXPECTED_STATE_DOMAIN
        ),
        "topology": (
            EXPECTED_TOPOLOGY
        ),
        "domain_independence": (
            True
        ),
        "cross_domain_coupling_gain": (
            0.0
        ),
        "equation_order": [
            "decode PHASE_U32 and Q16 state",
            "derive thermal node factors from soft and hard limits",
            "apply deterministic gamma target to class gamma nominal",
            "evaluate hierarchical Kuramoto-Sakaguchi coupling",
            "apply first-order delayed coupling",
            "update frequency target and delayed frequency current",
            "update phase velocity and PHASE_U32 phase",
            "update local thermal field",
            "project phase to balanced ternary {-1,0,1}",
        ],
        "coupling_equation": (
            "K * sum(w_ij * thermal_factor_i * thermal_factor_j * "
            "sin(phi_j - phi_i - gamma_i))"
        ),
        "delay_equation": (
            "d_i <- d_i + delay_alpha * (coupling_i - d_i)"
        ),
        "frequency_target_equation": (
            "f_target_i <- base_frequency + abs(d_i)"
        ),
        "frequency_delay_equation": (
            "f_i <- f_i + delay_alpha * (f_target_i - f_i)"
        ),
        "phase_velocity_equation": (
            "v_i <- phase_velocity_base_gain * f_i + "
            "scheduler_push_free + d_i"
        ),
        "phase_update_equation": (
            "phase_i <- PHASE_U32(phase_i + v_i)"
        ),
        "generated_heat_equation": (
            "generated_heat_i <- v_i^2"
        ),
        "thermal_dissipation_equation": (
            "(heat_i - ambient_heat) / thermal_time_constant"
        ),
        "thermal_diffusion_equation": (
            "thermal_diffusion_gain * sum(thermal_w_ij * (heat_j - heat_i))"
        ),
        "thermal_node_factor_rule": (
            "1 below soft limit, 0 at or above hard limit, linear between"
        ),
        "state_projection_rule": (
            EXPECTED_SHARED_PROBLEM_MODEL[
                "state_projection_rule"
            ]
        ),
        "operation_shape_examples": {
            str(
                size
            ): problem_operation_shape(
                size
            )
            for size
            in (
                8,
                16,
                32,
            )
        },
        "winner_assertions": [],
    }

    payload[
        "problem_contract_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    return payload


def _synthetic_initialization(
    nonlinearity_class: str,
) -> Any:
    require(
        nonlinearity_class
        in EXPECTED_NONLINEARITY_CLASSES,
        "invalid self-test nonlinearity_class",
    )

    class SyntheticInitialization:
        domain_size = 8

        domain_index = 0

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
                index
                * (
                    PHASE_MOD
                    // 8
                )
                + (
                    1
                    << 20
                )
            )
            & PHASE_MASK
            for index
            in range(
                8
            )
        )

        initial_frequency_target_q16 = tuple(
            Q16_SCALE
            for _ in range(
                8
            )
        )

        initial_frequency_current_q16 = tuple(
            Q16_SCALE
            for _ in range(
                8
            )
        )

        initial_heat_q16 = tuple(
            q16(
                0.05
            )
            for _ in range(
                8
            )
        )

    initialization = (
        SyntheticInitialization()
    )

    initialization.nonlinearity_class = (
        nonlinearity_class
    )

    return initialization


def _self_test_gamma_targets(
    tick: int,
    scale_q16: int,
    size: int,
) -> tuple[
    int,
    ...,
]:
    values = []

    span = (
        2
        * scale_q16
        + 1
    )

    for cell_index in range(
        size
    ):
        digest = hashlib.sha256(
            (
                f"problem-self-test:"
                f"{tick}:"
                f"{cell_index}"
            ).encode(
                "utf-8"
            )
        ).digest()

        raw = int.from_bytes(
            digest[
                :8
            ],
            "big",
        )

        values.append(
            (
                raw
                % span
            )
            - scale_q16
        )

    return tuple(
        values
    )


def run_self_test(
    profile: Mapping[
        str,
        Any,
    ],
) -> dict[
    str,
    Any,
]:
    validate_problem_profile(
        profile
    )

    for size in (
        8,
        16,
        32,
    ):
        for exponent in (
            0.7,
            1.2,
        ):
            first = (
                hierarchical_pair_weights(
                    size,
                    exponent,
                )
            )

            second = (
                hierarchical_pair_weights(
                    size,
                    exponent,
                )
            )

            require(
                first
                == second,
                "topology generation is not deterministic",
            )

    combined_trace: list[
        dict[
            str,
            Any,
        ]
    ] = []

    final_state_digests: dict[
        str,
        str,
    ] = {}

    for nonlinearity_class in (
        "low",
        "medium",
        "high",
    ):
        initialization = (
            _synthetic_initialization(
                nonlinearity_class
            )
        )

        state_a = build_problem_state(
            initialization
        )

        state_b = build_problem_state(
            initialization
        )

        require(
            state_a
            == state_b,
            "initial problem states differ",
        )

        scale_q16 = q16(
            profile[
                "nonlinearity_classes"
            ][
                nonlinearity_class
            ][
                "gamma_noise_target_scale"
            ]
        )

        trace_a: list[
            dict[
                str,
                Any,
            ]
        ] = []

        trace_b: list[
            dict[
                str,
                Any,
            ]
        ] = []

        for tick in range(
            32
        ):
            targets = (
                _self_test_gamma_targets(
                    tick,
                    scale_q16,
                    state_a.domain_size,
                )
            )

            result_a = (
                step_problem_domain(
                    profile,
                    state_a,
                    gamma_targets_q16=(
                        targets
                    ),
                )
            )

            result_b = (
                step_problem_domain(
                    profile,
                    state_b,
                    gamma_targets_q16=(
                        targets
                    ),
                )
            )

            require(
                result_a
                == result_b,
                "repeated problem execution is not deterministic",
            )

            state_a = (
                result_a.state
            )

            state_b = (
                result_b.state
            )

            trace_a.append(
                result_a.to_dict()
            )

            trace_b.append(
                result_b.to_dict()
            )

        require(
            trace_a
            == trace_b,
            "problem traces differ",
        )

        require(
            all(
                value
                in EXPECTED_STATE_DOMAIN
                for value
                in state_a.semantic_states
            ),
            "self-test escaped the balanced ternary state domain",
        )

        require(
            all(
                0
                <= value
                < PHASE_MOD
                for value
                in state_a.phase_words
            ),
            "self-test escaped PHASE_U32",
        )

        require(
            all(
                q16_to_float(
                    value
                )
                >= 0.05
                for value
                in state_a.heat_q16
            ),
            "self-test heat fell below ambient",
        )

        combined_trace.extend(
            trace_a
        )

        final_state_digests[
            nonlinearity_class
        ] = state_a.to_dict()[
            "problem_state_sha256"
        ]

    contract_a = (
        build_problem_contract_summary(
            profile
        )
    )

    contract_b = (
        build_problem_contract_summary(
            profile
        )
    )

    require(
        contract_a
        == contract_b,
        "problem contract is not deterministic",
    )

    trace_sha256 = sha256_hex(
        canonical_json_bytes(
            combined_trace
        )
    )

    return {
        "schema": (
            SELF_TEST_SCHEMA
        ),
        "status": (
            "PASS"
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "model_name": (
            EXPECTED_MODEL_NAME
        ),
        "nonlinearity_classes_tested": [
            "low",
            "medium",
            "high",
        ],
        "trace_length": (
            len(
                combined_trace
            )
        ),
        "final_problem_state_sha256": (
            final_state_digests
        ),
        "problem_trace_sha256": (
            trace_sha256
        ),
        "problem_contract_sha256": (
            contract_a[
                "problem_contract_sha256"
            ]
        ),
        "semantic_state_domain": list(
            EXPECTED_STATE_DOMAIN
        ),
        "domain_independence": (
            True
        ),
        "winner_assertions": [],
    }

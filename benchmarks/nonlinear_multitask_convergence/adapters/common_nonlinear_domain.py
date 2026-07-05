#!/usr/bin/env python3
"""Architecture-neutral deterministic domain construction for FRP multitask tests.

This module materializes the predeclared nonlinear multitask workload into
byte-stable domain initializations. It does not execute any architecture,
apply any ranking rule, or contain the FRP kernel.
"""

from __future__ import annotations

import hashlib
import json
import math
from dataclasses import dataclass
from typing import Any, Mapping, NoReturn, Sequence

SCHEMA = "frp.benchmark.nonlinear_multitask_domain_initialization.v1"
GENERATOR_NAME = "sha256_counter_domain_initializer_v1"

GENERATOR_DOMAIN = (
    b"frp-nonlinear-multitask-domain-v1\x00"
)

STATE_GENERATOR_DOMAIN = (
    b"frp-nonlinear-multitask-state-v1\x00"
)

PHASE_GENERATOR_DOMAIN = (
    b"frp-nonlinear-multitask-phase-v1\x00"
)

GAMMA_GENERATOR_DOMAIN = (
    b"frp-nonlinear-multitask-gamma-v1\x00"
)

TERNARY_STATES = (-1, 0, 1)

PHASE_MOD = 1 << 32
Q16_SCALE = 1 << 16

EXPECTED_SCHEDULER_MODE = "free"


class NonlinearDomainError(ValueError):
    """Raised when a nonlinear multitask domain contract is violated."""


def fail(message: str) -> NoReturn:
    raise NonlinearDomainError(message)


def require(
    condition: bool,
    message: str,
) -> None:
    if not condition:
        fail(message)


def canonical_json_bytes(
    value: Any,
) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        allow_nan=False,
    ).encode("utf-8")


def sha256_hex(
    data: bytes,
) -> str:
    return hashlib.sha256(data).hexdigest()


def _require_int(
    value: Any,
    name: str,
    *,
    minimum: int | None = None,
) -> int:
    require(
        not isinstance(value, bool)
        and isinstance(value, int),
        f"{name} must be an integer",
    )

    if minimum is not None:
        require(
            value >= minimum,
            f"{name} must be >= {minimum}",
        )

    return value


def _require_finite_number(
    value: Any,
    name: str,
) -> float:
    require(
        not isinstance(value, bool)
        and isinstance(value, (int, float)),
        f"{name} must be numeric",
    )

    numeric = float(value)

    require(
        math.isfinite(numeric),
        f"{name} must be finite",
    )

    return numeric


def _uint64(
    value: int,
    name: str,
) -> bytes:
    _require_int(
        value,
        name,
        minimum=0,
    )

    require(
        value <= 0xFFFFFFFFFFFFFFFF,
        f"{name} must fit uint64",
    )

    return value.to_bytes(
        8,
        byteorder="big",
        signed=False,
    )


def _uint32(
    value: int,
    name: str,
) -> bytes:
    _require_int(
        value,
        name,
        minimum=0,
    )

    require(
        value <= 0xFFFFFFFF,
        f"{name} must fit uint32",
    )

    return value.to_bytes(
        4,
        byteorder="big",
        signed=False,
    )


def _text_field(
    value: str,
    name: str,
) -> bytes:
    require(
        isinstance(value, str)
        and value,
        f"{name} must be a nonempty string",
    )

    encoded = value.encode("utf-8")

    require(
        len(encoded) <= 0xFFFF,
        f"{name} is too long",
    )

    return (
        len(encoded).to_bytes(
            2,
            byteorder="big",
        )
        + encoded
    )


def derive_domain_seed(
    *,
    seed: int,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
    domain_index: int,
) -> int:
    """Derive one deterministic uint64 domain seed from the workload tuple."""

    _require_int(
        domain_size,
        "domain_size",
        minimum=1,
    )

    _require_int(
        concurrent_domain_count,
        "concurrent_domain_count",
        minimum=1,
    )

    _require_int(
        domain_index,
        "domain_index",
        minimum=0,
    )

    require(
        domain_index
        < concurrent_domain_count,
        "domain_index must be smaller than "
        "concurrent_domain_count",
    )

    material = b"".join(
        [
            GENERATOR_DOMAIN,
            _uint64(
                seed,
                "seed",
            ),
            _uint32(
                domain_size,
                "domain_size",
            ),
            _uint32(
                concurrent_domain_count,
                "concurrent_domain_count",
            ),
            _text_field(
                nonlinearity_class,
                "nonlinearity_class",
            ),
            _uint32(
                domain_index,
                "domain_index",
            ),
        ]
    )

    return int.from_bytes(
        hashlib.sha256(
            material
        ).digest()[:8],
        byteorder="big",
        signed=False,
    )


def _uniform_int_from_hash(
    *,
    domain: bytes,
    material: bytes,
    low: int,
    high: int,
) -> int:
    """Return an exactly uniform deterministic integer in the closed interval."""

    require(
        low <= high,
        "uniform integer range is invalid",
    )

    span = high - low + 1
    modulus = 1 << 64

    acceptance_limit = (
        modulus
        - (
            modulus
            % span
        )
    )

    rejection_counter = 0

    while True:
        digest = hashlib.sha256(
            domain
            + material
            + _uint32(
                rejection_counter,
                "rejection_counter",
            )
        ).digest()

        raw = int.from_bytes(
            digest[:8],
            byteorder="big",
            signed=False,
        )

        if raw < acceptance_limit:
            return (
                low
                + (
                    raw
                    % span
                )
            )

        rejection_counter += 1


def _state_for_cell(
    domain_seed: int,
    cell_index: int,
) -> int:
    state_index = _uniform_int_from_hash(
        domain=STATE_GENERATOR_DOMAIN,
        material=(
            _uint64(
                domain_seed,
                "domain_seed",
            )
            + _uint32(
                cell_index,
                "cell_index",
            )
        ),
        low=0,
        high=(
            len(
                TERNARY_STATES
            )
            - 1
        ),
    )

    return TERNARY_STATES[
        state_index
    ]


def _phase_word_for_cell(
    domain_seed: int,
    cell_index: int,
) -> int:
    digest = hashlib.sha256(
        PHASE_GENERATOR_DOMAIN
        + _uint64(
            domain_seed,
            "domain_seed",
        )
        + _uint32(
            cell_index,
            "cell_index",
        )
    ).digest()

    return int.from_bytes(
        digest[:4],
        byteorder="big",
        signed=False,
    )


def _gamma_target_for_cell(
    *,
    domain_seed: int,
    tick: int,
    cell_index: int,
    scale_q16: int,
) -> int:
    return _uniform_int_from_hash(
        domain=GAMMA_GENERATOR_DOMAIN,
        material=(
            _uint64(
                domain_seed,
                "domain_seed",
            )
            + _uint64(
                tick,
                "tick",
            )
            + _uint32(
                cell_index,
                "cell_index",
            )
        ),
        low=-scale_q16,
        high=scale_q16,
    )


def _scale_to_q16(
    value: float,
) -> int:
    numeric = _require_finite_number(
        value,
        "gamma_noise_target_scale",
    )

    require(
        numeric >= 0.0,
        "gamma_noise_target_scale "
        "must be nonnegative",
    )

    return int(
        round(
            numeric
            * Q16_SCALE
        )
    )


@dataclass(frozen=True)
class DomainInitialization:
    """One byte-stable architecture-neutral domain preload."""

    domain_size: int

    concurrent_domain_count: int

    nonlinearity_class: str

    domain_index: int

    domain_seed: int

    initial_states: tuple[int, ...]

    initial_phase_words: tuple[int, ...]

    initial_frequency_target_q16: tuple[
        int,
        ...,
    ]

    initial_frequency_current_q16: tuple[
        int,
        ...,
    ]

    initial_heat_q16: tuple[
        int,
        ...,
    ]

    def to_payload(
        self,
    ) -> dict[str, Any]:
        return {
            "schema": SCHEMA,
            "generator": (
                GENERATOR_NAME
            ),
            "domain_size": (
                self.domain_size
            ),
            "concurrent_domain_count": (
                self.concurrent_domain_count
            ),
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "domain_index": (
                self.domain_index
            ),
            "domain_seed": (
                self.domain_seed
            ),
            "initial_states": list(
                self.initial_states
            ),
            "initial_phase_words": list(
                self.initial_phase_words
            ),
            "initial_frequency_target_q16": list(
                self.initial_frequency_target_q16
            ),
            "initial_frequency_current_q16": list(
                self.initial_frequency_current_q16
            ),
            "initial_heat_q16": list(
                self.initial_heat_q16
            ),
        }

    def sha256(
        self,
    ) -> str:
        return sha256_hex(
            canonical_json_bytes(
                self.to_payload()
            )
        )


def validate_profile_axes(
    profile: Mapping[str, Any],
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
        "initial benchmark scheduler_mode "
        "must be free",
    )

    require(
        profile.get(
            "seed"
        )
        == 76,
        "canonical workload seed must be 76",
    )

    require(
        profile.get(
            "transition_fraction"
        )
        == 0.25,
        "transition_fraction must remain 0.25",
    )

    require(
        profile.get(
            "auto_targets_enable"
        )
        is True,
        "auto_targets_enable must remain true",
    )

    domain_sizes = profile.get(
        "domain_size_order"
    )

    concurrent_counts = profile.get(
        "concurrent_domain_count_order"
    )

    nonlinearity_order = profile.get(
        "nonlinearity_class_order"
    )

    require(
        domain_sizes
        == [
            8,
            16,
            32,
        ],
        "domain_size_order mismatch",
    )

    require(
        concurrent_counts
        == [
            1,
            2,
            4,
            8,
        ],
        "concurrent_domain_count_order mismatch",
    )

    require(
        nonlinearity_order
        == [
            "low",
            "medium",
            "high",
        ],
        "nonlinearity_class_order mismatch",
    )

    classes = profile.get(
        "nonlinearity_classes"
    )

    require(
        isinstance(
            classes,
            Mapping,
        ),
        "nonlinearity_classes must be an object",
    )

    require(
        list(
            classes.keys()
        )
        == [
            "low",
            "medium",
            "high",
        ],
        "nonlinearity_classes key order mismatch",
    )

    initialization = profile.get(
        "deterministic_initialization"
    )

    require(
        isinstance(
            initialization,
            Mapping,
        ),
        "deterministic_initialization "
        "must be an object",
    )

    require(
        initialization.get(
            "initial_frequency_target_q16"
        )
        == 65536,
        "initial_frequency_target_q16 mismatch",
    )

    require(
        initialization.get(
            "initial_frequency_current_q16"
        )
        == 65536,
        "initial_frequency_current_q16 mismatch",
    )

    require(
        initialization.get(
            "initial_heat_q16"
        )
        == 3277,
        "initial_heat_q16 mismatch",
    )

    require(
        initialization.get(
            "same_initial_state_for_all_architectures"
        )
        is True,
        "same_initial_state_for_all_architectures "
        "must be true",
    )

    require(
        initialization.get(
            "same_initial_phase_for_all_architectures"
        )
        is True,
        "same_initial_phase_for_all_architectures "
        "must be true",
    )

    require(
        initialization.get(
            "same_gamma_noise_target_for_all_architectures"
        )
        is True,
        "same_gamma_noise_target_for_all_architectures "
        "must be true",
    )


def build_domain_initialization(
    profile: Mapping[str, Any],
    *,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
    domain_index: int,
) -> DomainInitialization:
    validate_profile_axes(
        profile
    )

    require(
        domain_size
        in profile[
            "domain_size_order"
        ],
        "domain_size is outside canonical axis",
    )

    require(
        concurrent_domain_count
        in profile[
            "concurrent_domain_count_order"
        ],
        "concurrent_domain_count "
        "is outside canonical axis",
    )

    require(
        nonlinearity_class
        in profile[
            "nonlinearity_class_order"
        ],
        "nonlinearity_class "
        "is outside canonical axis",
    )

    domain_seed = derive_domain_seed(
        seed=profile[
            "seed"
        ],
        domain_size=domain_size,
        concurrent_domain_count=(
            concurrent_domain_count
        ),
        nonlinearity_class=(
            nonlinearity_class
        ),
        domain_index=domain_index,
    )

    states: list[int] = []

    phase_words: list[int] = []

    for cell_index in range(
        domain_size
    ):
        states.append(
            _state_for_cell(
                domain_seed,
                cell_index,
            )
        )

        phase_words.append(
            _phase_word_for_cell(
                domain_seed,
                cell_index,
            )
        )

    initialization = profile[
        "deterministic_initialization"
    ]

    frequency_target = int(
        initialization[
            "initial_frequency_target_q16"
        ]
    )

    frequency_current = int(
        initialization[
            "initial_frequency_current_q16"
        ]
    )

    heat = int(
        initialization[
            "initial_heat_q16"
        ]
    )

    result = DomainInitialization(
        domain_size=domain_size,
        concurrent_domain_count=(
            concurrent_domain_count
        ),
        nonlinearity_class=(
            nonlinearity_class
        ),
        domain_index=(
            domain_index
        ),
        domain_seed=(
            domain_seed
        ),
        initial_states=tuple(
            states
        ),
        initial_phase_words=tuple(
            phase_words
        ),
        initial_frequency_target_q16=tuple(
            frequency_target
            for _ in range(
                domain_size
            )
        ),
        initial_frequency_current_q16=tuple(
            frequency_current
            for _ in range(
                domain_size
            )
        ),
        initial_heat_q16=tuple(
            heat
            for _ in range(
                domain_size
            )
        ),
    )

    validate_domain_initialization(
        result
    )

    return result


def validate_domain_initialization(
    value: DomainInitialization,
) -> None:
    require(
        value.domain_size
        in (
            8,
            16,
            32,
        ),
        "domain_size must be 8, 16, or 32",
    )

    require(
        value.concurrent_domain_count
        in (
            1,
            2,
            4,
            8,
        ),
        "concurrent_domain_count "
        "must be 1, 2, 4, or 8",
    )

    require(
        value.nonlinearity_class
        in (
            "low",
            "medium",
            "high",
        ),
        "invalid nonlinearity_class",
    )

    require(
        0
        <= value.domain_index
        < value.concurrent_domain_count,
        "invalid domain_index",
    )

    vectors: Sequence[
        Sequence[int]
    ] = (
        value.initial_states,
        value.initial_phase_words,
        value.initial_frequency_target_q16,
        value.initial_frequency_current_q16,
        value.initial_heat_q16,
    )

    require(
        all(
            len(vector)
            == value.domain_size
            for vector
            in vectors
        ),
        "initialization vector length mismatch",
    )

    require(
        all(
            state
            in TERNARY_STATES
            for state
            in value.initial_states
        ),
        "initial_states contain "
        "invalid ternary value",
    )

    require(
        all(
            0
            <= phase
            < PHASE_MOD
            for phase
            in value.initial_phase_words
        ),
        "initial_phase_words contain "
        "invalid phase",
    )


def build_case_initializations(
    profile: Mapping[str, Any],
    *,
    domain_size: int,
    concurrent_domain_count: int,
    nonlinearity_class: str,
) -> tuple[
    DomainInitialization,
    ...,
]:
    return tuple(
        build_domain_initialization(
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
            domain_index=(
                domain_index
            ),
        )
        for domain_index
        in range(
            concurrent_domain_count
        )
    )


def gamma_noise_targets_q16(
    profile: Mapping[str, Any],
    initialization: DomainInitialization,
    *,
    tick: int,
) -> tuple[int, ...]:
    """Return deterministic signed Q16 gamma-noise targets for one domain tick."""

    _require_int(
        tick,
        "tick",
        minimum=0,
    )

    validate_domain_initialization(
        initialization
    )

    class_profile = profile[
        "nonlinearity_classes"
    ][
        initialization.nonlinearity_class
    ]

    scale_q16 = _scale_to_q16(
        class_profile[
            "gamma_noise_target_scale"
        ]
    )

    targets: list[int] = []

    for cell_index in range(
        initialization.domain_size
    ):
        targets.append(
            _gamma_target_for_cell(
                domain_seed=(
                    initialization.domain_seed
                ),
                tick=tick,
                cell_index=(
                    cell_index
                ),
                scale_q16=(
                    scale_q16
                ),
            )
        )

    return tuple(
        targets
    )


def build_initialization_manifest(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    validate_profile_axes(
        profile
    )

    cases: list[
        dict[str, Any]
    ] = []

    for domain_size in profile[
        "domain_size_order"
    ]:
        for concurrent_domain_count in profile[
            "concurrent_domain_count_order"
        ]:
            for nonlinearity_class in profile[
                "nonlinearity_class_order"
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

                cases.append(
                    {
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
                            item.sha256()
                            for item
                            in initializations
                        ],
                    }
                )

    payload = {
        "schema": (
            "frp.benchmark."
            "nonlinear_multitask_"
            "initialization_manifest.v1"
        ),
        "generator": (
            GENERATOR_NAME
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "seed": profile[
            "seed"
        ],
        "case_count": len(
            cases
        ),
        "cases": cases,
    }

    payload[
        "initialization_manifest_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    return payload


def run_self_test(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    validate_profile_axes(
        profile
    )

    first = build_domain_initialization(
        profile,
        domain_size=8,
        concurrent_domain_count=2,
        nonlinearity_class="medium",
        domain_index=1,
    )

    second = build_domain_initialization(
        profile,
        domain_size=8,
        concurrent_domain_count=2,
        nonlinearity_class="medium",
        domain_index=1,
    )

    require(
        first
        == second,
        "repeated domain initialization "
        "is not deterministic",
    )

    require(
        first.sha256()
        == second.sha256(),
        "repeated initialization digest mismatch",
    )

    gamma_first = gamma_noise_targets_q16(
        profile,
        first,
        tick=0,
    )

    gamma_second = gamma_noise_targets_q16(
        profile,
        second,
        tick=0,
    )

    gamma_next = gamma_noise_targets_q16(
        profile,
        first,
        tick=1,
    )

    require(
        gamma_first
        == gamma_second,
        "repeated gamma targets "
        "are not deterministic",
    )

    require(
        len(
            gamma_first
        )
        == first.domain_size,
        "gamma target length mismatch",
    )

    require(
        gamma_first
        != gamma_next,
        "gamma targets must vary across ticks",
    )

    manifest_first = build_initialization_manifest(
        profile
    )

    manifest_second = build_initialization_manifest(
        profile
    )

    require(
        manifest_first
        == manifest_second,
        "initialization manifest "
        "is not deterministic",
    )

    require(
        manifest_first[
            "case_count"
        ]
        == 36,
        "initialization manifest "
        "case_count mismatch",
    )

    return {
        "status": "PASS",
        "domain_initialization_sha256": (
            first.sha256()
        ),
        "gamma_tick_0_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    list(
                        gamma_first
                    )
                )
            )
        ),
        "initialization_manifest_sha256": (
            manifest_first[
                "initialization_manifest_sha256"
            ]
        ),
        "case_count": (
            manifest_first[
                "case_count"
            ]
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
    }

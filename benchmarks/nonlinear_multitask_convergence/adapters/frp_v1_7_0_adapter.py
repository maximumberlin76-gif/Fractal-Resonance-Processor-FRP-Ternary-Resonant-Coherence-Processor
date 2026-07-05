#!/usr/bin/env python3
"""FRP v1.7.0 M15 adapter for the nonlinear multitask benchmark.

The first benchmark stage is hard-locked to ``scheduler_mode = free``. This
adapter imports the exact repository M15 quantized shadow processor, binds it
to the predeclared nonlinear workload parameters and deterministic domain
initialization, and exposes one architecture event packet per M15 processor
tick. The FRP kernel is not copied or reimplemented here.
"""

from __future__ import annotations

import copy
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence

ADAPTER_SCHEMA = "frp.benchmark.nonlinear_multitask.frp_v1_7_0_adapter.v1"
STEP_SCHEMA = "frp.benchmark.nonlinear_multitask.frp_v1_7_0_step.v1"
CONTRACT_SCHEMA = "frp.benchmark.nonlinear_multitask.frp_v1_7_0_contract.v1"
SELF_TEST_SCHEMA = (
    "frp.benchmark.nonlinear_multitask.frp_v1_7_0_adapter.self_test.v1"
)

ARCHITECTURE_ID = "frp_v1_7_0_quantized_shadow"
ARCHITECTURE_NAME = "FRP v1.7.0 Quantized Hardware Shadow Reference"
EXPECTED_SCHEDULER_MODE = "free"
EXPECTED_VERSION = "1.7.0"
EXPECTED_MILESTONE = (
    "M15 — Implementation Mapping, Domain Interface, and Qualification "
    "Closure Package"
)
EXPECTED_TRANSITION_FRACTION = 0.25
EXPECTED_FRP_SOURCE_SHA256 = (
    "a65e2c352157ac5b0fc34b3a09605bad53cd62a1ae0d39855ed35f979b507f85"
)

EVENT_ACCOUNTING_PROFILE = "m15_shadow_algorithmic_event_accounting_v1"
STATE_BITS_PER_CELL = 2
EVENT_PACKET_PHASE_ORDER = ("m15_quantized_shadow_tick",)

ADAPTER_DIR = Path(__file__).resolve().parent
REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
BENCHMARKS_DIR = Path(__file__).resolve().parents[2]
ARCHITECTURE_COMPARISON_DIR = BENCHMARKS_DIR / "architecture_comparison"
FRP_SOURCE_PATH = REPOSITORY_ROOT / "frp_prototype_v1_7_0.py"
WORKLOAD_PROFILE_PATH = (
    BENCHMARKS_DIR
    / "nonlinear_multitask_convergence"
    / "workloads"
    / "nonlinear_multitask_workload_v1.json"
)

for import_path in (
    ADAPTER_DIR,
    ARCHITECTURE_COMPARISON_DIR,
    REPOSITORY_ROOT,
):
    if str(import_path) not in sys.path:
        sys.path.insert(0, str(import_path))

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
        canonical_json_bytes,
        sha256_hex,
        validate_problem_profile,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the shared nonlinear multitask problem contract"
    ) from exc


class FRPv170AdapterError(ValueError):
    """Raised when the M15 nonlinear multitask adapter contract is violated."""


def fail(message: str) -> NoReturn:
    raise FRPv170AdapterError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def sha256_file(path: Path) -> str:
    require(path.is_file(), f"bound file not found: {path}")

    digest = hashlib.sha256()

    try:
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
    except OSError as exc:
        fail(f"unable to hash bound file {path}: {exc}")

    return digest.hexdigest()


def verify_frp_source() -> str:
    digest = sha256_file(FRP_SOURCE_PATH)

    require(
        digest == EXPECTED_FRP_SOURCE_SHA256,
        "frp_prototype_v1_7_0.py SHA-256 mismatch: "
        f"expected {EXPECTED_FRP_SOURCE_SHA256}, got {digest}",
    )

    return digest


FRP_SOURCE_SHA256 = verify_frp_source()

try:
    from frp_prototype_v1_7_0 import (  # noqa: E402
        MILESTONE,
        Q16_SCALE,
        TERNARY_STATES,
        VERSION,
        QuantizedReferenceShadowProcessor,
        phase_order_q30,
        state_to_code,
    )
except ImportError as exc:
    raise RuntimeError(
        "unable to import the exact FRP v1.7.0 M15 quantized shadow kernel"
    ) from exc

require(VERSION == EXPECTED_VERSION, f"unexpected FRP version: {VERSION}")
require(MILESTONE == EXPECTED_MILESTONE, f"unexpected FRP milestone: {MILESTONE}")
require(tuple(TERNARY_STATES) == (-1, 0, 1), "unexpected FRP ternary state domain")


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
        require(value >= minimum, f"{name} must be >= {minimum}")

    return value


def _encoded_bit_toggle_count(
    before: Sequence[int],
    after: Sequence[int],
) -> int:
    require(len(before) == len(after), "FRP state vector length mismatch")

    return sum(
        (state_to_code(previous) ^ state_to_code(current)).bit_count()
        for previous, current in zip(before, after)
    )


def _static_algorithmic_operation_counts(
    *,
    cells: int,
    hierarchy_depth: int,
) -> dict[str, int]:
    """Return the repository-established per-cycle M15 primitive counts."""

    pair_count = cells * (cells - 1)

    return {
        "lut_reads_32": (
            pair_count
            + 2 * cells * (1 + hierarchy_depth)
            + cells
            + 1
        ),
        "fixed_point_multiplies_32x32": (
            4 * pair_count
            + 18 * cells
            + 8
        ),
        "fixed_point_accumulates_64": (
            2 * pair_count
            + 2 * cells * hierarchy_depth
            + 7 * cells
            - 2
        ),
        "fixed_point_adds_32": (
            2 * pair_count
            + 21 * cells
            + 7
        ),
        "fixed_point_compares_32": (
            7 * cells
            + 2
            - hierarchy_depth
        ),
    }


def _event_accounting_contract(
    *,
    cells: int,
    hierarchy_depth: int,
    request_lanes: int,
) -> dict[str, Any]:
    return {
        "profile_name": EVENT_ACCOUNTING_PROFILE,
        "granularity": "M15 architecture-level algorithmic primitives",
        "excluded_from_counting": [
            "Python interpreter instructions",
            "helper-internal saturation branches",
            "host memory allocation",
            "host serialization",
            "host runtime overhead",
        ],
        "state_clock_model": "synchronous 2-bit ternary state domain",
        "clocked_state_bits_per_cycle": cells * STATE_BITS_PER_CELL,
        "state_register_write_bits_per_logical_change": STATE_BITS_PER_CELL,
        "request_lanes": request_lanes,
        "static_per_cycle_operation_counts": _static_algorithmic_operation_counts(
            cells=cells,
            hierarchy_depth=hierarchy_depth,
        ),
        "dynamic_event_rules": {
            "encoded_bit_toggles": (
                "2-bit Hamming distance between pre-tick and post-tick "
                "FRP state encodings"
            ),
            "logical_state_changes": (
                "count of cells whose ternary state changes during the M15 tick"
            ),
            "queue_reads": (
                "pending neutral-route entries present at M15 tick entry"
            ),
            "queue_writes": (
                "new M15 route_events with route_status=pending"
            ),
            "comparison_events": (
                "scheduler selection, request-lane normalization, pending-route "
                "control, auto-target scan control, and queue-capacity control"
            ),
            "control_events": "one M15 processor-cycle control event",
        },
    }


def _validate_initialization(initialization: Any) -> None:
    required_attributes = (
        "domain_size",
        "domain_index",
        "domain_seed",
        "nonlinearity_class",
        "initial_states",
        "initial_phase_words",
        "initial_frequency_target_q16",
        "initial_frequency_current_q16",
        "initial_heat_q16",
    )

    for attribute in required_attributes:
        require(
            hasattr(initialization, attribute),
            f"initialization missing attribute: {attribute}",
        )

    size = require_int(initialization.domain_size, "domain_size", 2)
    require(size in (8, 16, 32), "domain_size must be 8, 16, or 32")
    require_int(initialization.domain_index, "domain_index", 0)
    require_int(initialization.domain_seed, "domain_seed", 0)

    vectors = (
        initialization.initial_states,
        initialization.initial_phase_words,
        initialization.initial_frequency_target_q16,
        initialization.initial_frequency_current_q16,
        initialization.initial_heat_q16,
    )

    require(
        all(len(vector) == size for vector in vectors),
        "initialization vector length mismatch",
    )
    require(
        all(state in TERNARY_STATES for state in initialization.initial_states),
        "initial states must remain in {-1, 0, 1}",
    )
    require(
        all(
            not isinstance(word, bool)
            and isinstance(word, int)
            and 0 <= word < PHASE_MOD
            for word in initialization.initial_phase_words
        ),
        "initial phase words must remain in PHASE_U32",
    )
    require(
        all(
            not isinstance(value, bool) and isinstance(value, int)
            for vector in vectors[2:]
            for value in vector
        ),
        "initial Q16 vectors must contain integers",
    )


def _preload_processor(
    processor: QuantizedReferenceShadowProcessor,
    initialization: Any,
) -> None:
    """Load the common deterministic domain state into the exact M15 object."""

    _validate_initialization(initialization)

    require(
        processor.cells == initialization.domain_size,
        "processor and initialization domain sizes differ",
    )

    processor.states = [int(value) for value in initialization.initial_states]
    processor.phase_words = [
        int(value) for value in initialization.initial_phase_words
    ]
    processor.base_frequency_q16 = [
        int(value) for value in initialization.initial_frequency_target_q16
    ]
    processor.frequency_target_q16 = list(processor.base_frequency_q16)
    processor.frequency_current_q16 = [
        int(value) for value in initialization.initial_frequency_current_q16
    ]
    processor.frequency_lag_q16 = [
        abs(target - current)
        for target, current in zip(
            processor.frequency_target_q16,
            processor.frequency_current_q16,
        )
    ]

    processor.heat_q16 = [int(value) for value in initialization.initial_heat_q16]
    processor.local_heat_peak_q16 = list(processor.heat_q16)
    processor.generated_power_q16 = [0 for _ in range(processor.cells)]
    processor.thermal_dissipation_q16 = [0 for _ in range(processor.cells)]
    processor.thermal_diffusion_q16 = [0 for _ in range(processor.cells)]
    processor.thermal_overload_q16 = [
        max(0, value - processor.thermal_soft_limit_q16)
        for value in processor.heat_q16
    ]

    processor.gamma_noise_state_q16 = [0 for _ in range(processor.cells)]
    processor.gamma_noise_target_q16 = [0 for _ in range(processor.cells)]
    processor.gamma_effective_word = [
        processor.gamma_nominal_word for _ in range(processor.cells)
    ]
    processor.gamma_drift_word = [0 for _ in range(processor.cells)]

    processor.coupling_field_q16 = [0 for _ in range(processor.cells)]
    processor.phase_velocity_word = [0 for _ in range(processor.cells)]

    processor.transition_requests = []
    processor.pending_neutral_routes = []
    processor.route_events = []
    processor.actual_direct_events = 0
    processor.requested_direct_events = 0
    processor.prevented_direct_events = 0
    processor.neutral_routed_events = 0
    processor.neutralized_conflicts = 0
    processor.reserved_state_events = 0
    processor.queue_overflow_events = 0

    processor.scheduler_counts = {}
    processor.cell_switch_activity = [0 for _ in range(processor.cells)]
    processor.current_switch_changes = 0
    processor.switch_load_q16 = 0
    processor.switch_load_peak_q16 = 0
    processor.tick_count = 0
    processor.trace = []
    processor.cell_trace = []
    processor.first_boundary_crossing = None

    processor.raw_phase_coherence_q30 = phase_order_q30(processor.phase_words)
    processor.update_thermal_node_factors()
    multiscale = processor.multiscale_phase_coherence()
    processor.update_global_stability(multiscale)
    processor.previous_C_minus_P_q16 = processor.C_minus_P_q16

    require(
        tuple(processor.states) == tuple(initialization.initial_states),
        "M15 state preload mismatch",
    )
    require(
        tuple(processor.phase_words) == tuple(initialization.initial_phase_words),
        "M15 PHASE_U32 preload mismatch",
    )
    require(
        processor.actual_direct_events == 0,
        "M15 preload created a direct polarity event",
    )
    require(
        len(processor.pending_neutral_routes) == 0,
        "M15 preload must start with an empty neutral-route queue",
    )


def _validate_gamma_targets(
    profile: Mapping[str, Any],
    nonlinearity_class: str,
    gamma_targets_q16: Sequence[int],
    cells: int,
) -> tuple[int, ...]:
    require(
        not isinstance(gamma_targets_q16, (str, bytes, bytearray)),
        "gamma_targets_q16 must be a sequence",
    )

    targets = tuple(gamma_targets_q16)
    require(len(targets) == cells, "gamma target vector length mismatch")
    require(
        all(
            not isinstance(value, bool) and isinstance(value, int)
            for value in targets
        ),
        "gamma targets must be integer Q16 values",
    )

    class_profile = profile["nonlinearity_classes"][nonlinearity_class]
    scale_q16 = int(
        round(
            float(
                class_profile["gamma_noise_target_scale"]
            )
            * Q16_SCALE
        )
    )

    require(
        all(-scale_q16 <= value <= scale_q16 for value in targets),
        "gamma target exceeds the predeclared class scale",
    )

    return targets


def _build_cycle_events(
    processor: QuantizedReferenceShadowProcessor,
    *,
    states_before: Sequence[int],
    states_after: Sequence[int],
    pending_before: int,
    new_route_events: Sequence[Mapping[str, Any]],
    auto_targets_enable: bool,
) -> tuple[dict[str, int], int, int]:
    events = empty_event_counts()

    logical_changes = sum(
        1
        for before, after in zip(states_before, states_after)
        if before != after
    )

    encoded_toggles = _encoded_bit_toggle_count(
        states_before,
        states_after,
    )

    queue_writes = sum(
        1
        for row in new_route_events
        if row.get("route_status") == "pending"
    )

    events["encoded_bit_toggles"] = encoded_toggles
    events["clocked_state_bits"] = processor.cells * STATE_BITS_PER_CELL
    events["register_write_bits"] = logical_changes * STATE_BITS_PER_CELL
    events["comparison_events"] = (
        2
        + 2 * processor.request_lanes
        + 4 * pending_before
        + queue_writes
        + (
            2 * processor.cells
            if auto_targets_enable
            else 0
        )
    )
    events["control_events"] = 1
    events["queue_reads"] = pending_before
    events["queue_writes"] = queue_writes

    for event_field, count in _static_algorithmic_operation_counts(
        cells=processor.cells,
        hierarchy_depth=processor.hierarchy_depth,
    ).items():
        events[event_field] = count

    return (
        validate_event_counts(events),
        logical_changes,
        encoded_toggles,
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
class FRPv170StepResult:
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


class FRPv170NonlinearMultitaskAdapter:
    """Exact M15 quantized-shadow execution adapter for one nonlinear domain."""

    def __init__(
        self,
        profile: Mapping[str, Any],
        initialization: Any,
    ) -> None:
        validate_problem_profile(profile)
        _validate_initialization(initialization)

        require(
            profile.get("scheduler_mode") == EXPECTED_SCHEDULER_MODE,
            "initial benchmark scheduler_mode must be free",
        )

        require(
            profile.get("transition_fraction")
            == EXPECTED_TRANSITION_FRACTION,
            "transition_fraction must remain 0.25",
        )

        require(
            profile.get("auto_targets_enable") is True,
            "auto_targets_enable must remain true",
        )

        self.profile = copy.deepcopy(
            dict(profile)
        )

        self.domain_size = int(
            initialization.domain_size
        )

        self.domain_index = int(
            initialization.domain_index
        )

        self.domain_seed = int(
            initialization.domain_seed
        )

        self.nonlinearity_class = str(
            initialization.nonlinearity_class
        )

        require(
            self.nonlinearity_class
            in self.profile["nonlinearity_classes"],
            "invalid nonlinearity_class",
        )

        shared = self.profile[
            "shared_problem_model"
        ]

        selected = self.profile[
            "nonlinearity_classes"
        ][
            self.nonlinearity_class
        ]

        self.processor = QuantizedReferenceShadowProcessor(
            cells=self.domain_size,
            transition_fraction=EXPECTED_TRANSITION_FRACTION,
            gamma_nominal=float(
                selected["gamma_nominal_radians"]
            ),
            scheduler=EXPECTED_SCHEDULER_MODE,
            seed=self.domain_seed,
            fractal_alpha=float(
                shared["fractal_alpha"]
            ),
            thermal_beta=float(
                shared["thermal_beta"]
            ),
            ambient_heat=float(
                shared["ambient_heat"]
            ),
            thermal_time_constant=float(
                shared["thermal_time_constant"]
            ),
            thermal_soft_limit=float(
                shared["thermal_soft_limit"]
            ),
            thermal_hard_limit=float(
                shared["thermal_hard_limit"]
            ),
            coupling_nominal=float(
                selected["coupling_nominal"]
            ),
            delay_alpha=float(
                selected["delay_alpha"]
            ),
            thermal_diffusion_gain=float(
                shared["thermal_diffusion_gain"]
            ),
        )

        _preload_processor(
            self.processor,
            initialization,
        )

        require(
            self.processor.scheduler
            == EXPECTED_SCHEDULER_MODE,
            "M15 scheduler must remain free",
        )

        require(
            self.processor.transition_fraction
            == EXPECTED_TRANSITION_FRACTION,
            "M15 transition fraction mismatch",
        )

        self.initial_preload = (
            self.processor.snapshot_preload()
        )

        self.logical_updates = 0
        self.quiescence_ticks = 0
        self.quiescence_started = False
        self.event_totals = empty_event_counts()
        self.logical_state_changes = 0
        self.encoded_bit_toggles = 0
        self.neutral_insertions = 0
        self.pending_route_peak = 0

        self.step_trace_sha256: list[
            str
        ] = []

        self.quiescence_trace_sha256: list[
            str
        ] = []

    @property
    def semantic_states(
        self,
    ) -> tuple[int, ...]:
        return tuple(
            self.processor.states
        )

    @property
    def phase_words(
        self,
    ) -> tuple[int, ...]:
        return tuple(
            self.processor.phase_words
        )

    def _assert_frp_invariants(
        self,
    ) -> None:
        require(
            self.processor.actual_direct_events == 0,
            "FRP invariant violated: "
            "actual_direct_events must remain 0",
        )

        require(
            self.processor.reserved_state_events == 0,
            "FRP invariant violated: "
            "reserved_state_events must remain 0",
        )

        require(
            self.processor.queue_overflow_events == 0,
            "FRP invariant violated: "
            "queue_overflow_events must remain 0",
        )

        require(
            all(
                state in TERNARY_STATES
                for state in self.processor.states
            ),
            "FRP state escaped {-1, 0, 1}",
        )

        require(
            all(
                0 <= word < PHASE_MOD
                for word in self.processor.phase_words
            ),
            "FRP phase escaped PHASE_U32",
        )

        require(
            len(
                self.processor.pending_neutral_routes
            )
            <= self.processor.neutral_route_queue_capacity,
            "FRP pending-route queue exceeded capacity",
        )

    def step(
        self,
        *,
        gamma_targets_q16: Sequence[int],
    ) -> FRPv170StepResult:
        targets = _validate_gamma_targets(
            self.profile,
            self.nonlinearity_class,
            gamma_targets_q16,
            self.domain_size,
        )

        require(
            not self.quiescence_started,
            "logical workload updates cannot resume after "
            "terminal quiescence has started",
        )

        require(
            self.processor.tick_count
            == (
                self.logical_updates
                + self.quiescence_ticks
            ),
            "M15 tick counter diverged from adapter "
            "logical-update plus quiescence-tick counters",
        )

        states_before = list(
            self.processor.states
        )

        phase_words_before = list(
            self.processor.phase_words
        )

        pending_before = len(
            self.processor.pending_neutral_routes
        )

        route_event_start = len(
            self.processor.route_events
        )

        neutral_routed_before = (
            self.processor.neutral_routed_events
        )

        prevented_before = (
            self.processor.prevented_direct_events
        )

        neutralized_before = (
            self.processor.neutralized_conflicts
        )

        actual_direct_before = (
            self.processor.actual_direct_events
        )

        tick_index = self.processor.tick_count

        m15_row = self.processor.tick(
            tick_index,
            requests=[],
            auto_targets_enable=True,
            gamma_update_valid=True,
            gamma_targets_q16=targets,
        )

        states_after = list(
            self.processor.states
        )

        phase_words_after = list(
            self.processor.phase_words
        )

        new_route_events = (
            self.processor.route_events[
                route_event_start:
            ]
        )

        (
            event_packet,
            logical_changes,
            encoded_toggles,
        ) = _build_cycle_events(
            self.processor,
            states_before=states_before,
            states_after=states_after,
            pending_before=pending_before,
            new_route_events=new_route_events,
            auto_targets_enable=True,
        )

        event_packets = (
            event_packet,
        )

        event_totals = (
            aggregate_event_packets(
                event_packets
            )
        )

        for field in EVENT_FIELDS:
            self.event_totals[field] += (
                event_totals[field]
            )

        self.logical_state_changes += (
            logical_changes
        )

        self.encoded_bit_toggles += (
            encoded_toggles
        )

        self.neutral_insertions += (
            self.processor.neutral_routed_events
            - neutral_routed_before
        )

        self.pending_route_peak = max(
            self.pending_route_peak,
            pending_before,
            len(
                self.processor.pending_neutral_routes
            ),
        )

        self._assert_frp_invariants()

        require(
            self.processor.actual_direct_events
            == actual_direct_before,
            "FRP tick created a direct "
            "opposite-polarity transition",
        )

        logical_update_id = (
            f"{ARCHITECTURE_ID}:"
            f"domain-{self.domain_index}:"
            f"iteration-{self.logical_updates}"
        )

        metadata: dict[str, Any] = {
            "logical_update_id": (
                logical_update_id
            ),
            "domain_index": (
                self.domain_index
            ),
            "domain_size": (
                self.domain_size
            ),
            "domain_seed": (
                self.domain_seed
            ),
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "logical_iteration_before": (
                self.logical_updates
            ),
            "logical_iteration_after": (
                self.logical_updates + 1
            ),
            "frp_reference": {
                "version": VERSION,
                "milestone": MILESTONE,
                "source_file": (
                    "frp_prototype_v1_7_0.py"
                ),
                "source_sha256": (
                    FRP_SOURCE_SHA256
                ),
                "processor_class": (
                    "QuantizedReferenceShadowProcessor"
                ),
                "execution_model": (
                    "stateful fixed-point feedback"
                ),
            },
            "m15_tick": (
                tick_index
            ),
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "scheduler_state_name": (
                m15_row["scheduler_state_name"]
            ),
            "transition_fraction": (
                self.processor.transition_fraction
            ),
            "request_lanes": (
                self.processor.request_lanes
            ),
            "auto_targets_enable": (
                True
            ),
            "active_neutral_state": (
                True
            ),
            "direct_opposite_polarity_transition": (
                "forbidden"
            ),
            "mandatory_routes": [
                "-1 -> 0 -> 1",
                "1 -> 0 -> -1",
            ],
            "tick_separated_neutral_route": (
                True
            ),
            "scheduler_7_1_enabled": (
                False
            ),
            "scheduler_1_7_enabled": (
                False
            ),
            "states_before": (
                states_before
            ),
            "states_after": (
                states_after
            ),
            "phase_words_before": (
                phase_words_before
            ),
            "phase_words_after": (
                phase_words_after
            ),
            "logical_state_changes": (
                logical_changes
            ),
            "encoded_bit_toggles": (
                encoded_toggles
            ),
            "pending_route_count_before": (
                pending_before
            ),
            "pending_route_count_after": len(
                self.processor.pending_neutral_routes
            ),
            "new_route_events": [
                dict(row)
                for row in new_route_events
            ],
            "prevented_direct_events_delta": (
                self.processor.prevented_direct_events
                - prevented_before
            ),
            "neutral_routed_events_delta": (
                self.processor.neutral_routed_events
                - neutral_routed_before
            ),
            "neutralized_conflicts_delta": (
                self.processor.neutralized_conflicts
                - neutralized_before
            ),
            "actual_direct_events": (
                self.processor.actual_direct_events
            ),
            "reserved_state_events": (
                self.processor.reserved_state_events
            ),
            "queue_overflow_events": (
                self.processor.queue_overflow_events
            ),
            "event_packet_count": (
                1
            ),
            "event_packet_phase_order": list(
                EVENT_PACKET_PHASE_ORDER
            ),
            "event_totals": (
                event_totals
            ),
            "m15_trace_row": copy.deepcopy(
                dict(m15_row)
            ),
            "winner_assertions": [],
        }

        result = FRPv170StepResult(
            architecture_id=(
                ARCHITECTURE_ID
            ),
            architecture_name=(
                ARCHITECTURE_NAME
            ),
            scheduler_mode=(
                EXPECTED_SCHEDULER_MODE
            ),
            semantic_states=tuple(
                states_after
            ),
            phase_words=tuple(
                phase_words_after
            ),
            event_packets=(
                event_packets
            ),
            logical_update_metadata=(
                metadata
            ),
        )

        result_payload = (
            result.to_dict()
        )

        self.logical_updates += 1

        self.step_trace_sha256.append(
            result_payload[
                "adapter_step_sha256"
            ]
        )

        return result

    def quiescence_step(
        self,
    ) -> FRPv170StepResult:
        """Advance only already-pending M15 neutral routes by one processor tick.

        This operation is terminal-only. It disables automatic target creation,
        submits no transition requests, does not advance the benchmark logical
        workload, and still emits the normal architecture event packet so the
        common cost and thermal layers can account for the physical completion
        of an already-started tick-separated neutral route.
        """

        require(
            self.processor.tick_count
            == (
                self.logical_updates
                + self.quiescence_ticks
            ),
            "M15 tick counter diverged from adapter "
            "logical-update plus quiescence-tick counters",
        )

        require(
            len(
                self.processor.pending_neutral_routes
            )
            > 0,
            "terminal quiescence requires at least one "
            "pending neutral route",
        )

        require(
            len(
                self.processor.transition_requests
            )
            == 0,
            "terminal quiescence cannot begin with queued "
            "transition requests",
        )

        self.quiescence_started = True

        states_before = list(
            self.processor.states
        )

        phase_words_before = list(
            self.processor.phase_words
        )

        pending_before = len(
            self.processor.pending_neutral_routes
        )

        route_event_start = len(
            self.processor.route_events
        )

        neutral_routed_before = (
            self.processor.neutral_routed_events
        )

        prevented_before = (
            self.processor.prevented_direct_events
        )

        neutralized_before = (
            self.processor.neutralized_conflicts
        )

        actual_direct_before = (
            self.processor.actual_direct_events
        )

        tick_index = self.processor.tick_count

        m15_row = self.processor.tick(
            tick_index,
            requests=[],
            auto_targets_enable=False,
            gamma_update_valid=False,
            gamma_targets_q16=None,
        )

        states_after = list(
            self.processor.states
        )

        phase_words_after = list(
            self.processor.phase_words
        )

        new_route_events = (
            self.processor.route_events[
                route_event_start:
            ]
        )

        (
            event_packet,
            logical_changes,
            encoded_toggles,
        ) = _build_cycle_events(
            self.processor,
            states_before=states_before,
            states_after=states_after,
            pending_before=pending_before,
            new_route_events=new_route_events,
            auto_targets_enable=False,
        )

        event_packets = (
            event_packet,
        )

        event_totals = (
            aggregate_event_packets(
                event_packets
            )
        )

        for field in EVENT_FIELDS:
            self.event_totals[field] += (
                event_totals[field]
            )

        self.logical_state_changes += (
            logical_changes
        )

        self.encoded_bit_toggles += (
            encoded_toggles
        )

        self.pending_route_peak = max(
            self.pending_route_peak,
            pending_before,
            len(
                self.processor.pending_neutral_routes
            ),
        )

        self._assert_frp_invariants()

        require(
            self.processor.actual_direct_events
            == actual_direct_before,
            "terminal quiescence created a direct "
            "opposite-polarity transition",
        )

        require(
            self.processor.neutral_routed_events
            == neutral_routed_before,
            "terminal quiescence created a new neutral route",
        )

        require(
            self.processor.prevented_direct_events
            == prevented_before,
            "terminal quiescence processed a new direct request",
        )

        require(
            self.processor.neutralized_conflicts
            == neutralized_before,
            "terminal quiescence created a new conflict",
        )

        require(
            not any(
                row.get("route_status") == "pending"
                for row in new_route_events
            ),
            "terminal quiescence enqueued a new pending route",
        )

        require(
            len(
                self.processor.pending_neutral_routes
            )
            < pending_before,
            "terminal quiescence made no progress toward "
            "an empty pending-route queue",
        )

        quiescence_update_id = (
            f"{ARCHITECTURE_ID}:"
            f"domain-{self.domain_index}:"
            f"quiescence-{self.quiescence_ticks}"
        )

        metadata: dict[str, Any] = {
            "logical_update_id": (
                quiescence_update_id
            ),
            "step_kind": (
                "terminal_quiescence"
            ),
            "terminal_quiescence": (
                True
            ),
            "advances_logical_workload": (
                False
            ),
            "new_logical_routes_allowed": (
                False
            ),
            "domain_index": (
                self.domain_index
            ),
            "domain_size": (
                self.domain_size
            ),
            "domain_seed": (
                self.domain_seed
            ),
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "logical_iteration_before": (
                self.logical_updates
            ),
            "logical_iteration_after": (
                self.logical_updates
            ),
            "quiescence_tick_before": (
                self.quiescence_ticks
            ),
            "quiescence_tick_after": (
                self.quiescence_ticks + 1
            ),
            "frp_reference": {
                "version": VERSION,
                "milestone": MILESTONE,
                "source_file": (
                    "frp_prototype_v1_7_0.py"
                ),
                "source_sha256": (
                    FRP_SOURCE_SHA256
                ),
                "processor_class": (
                    "QuantizedReferenceShadowProcessor"
                ),
                "execution_model": (
                    "stateful fixed-point feedback"
                ),
            },
            "m15_tick": (
                tick_index
            ),
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "scheduler_state_name": (
                m15_row["scheduler_state_name"]
            ),
            "transition_fraction": (
                self.processor.transition_fraction
            ),
            "request_lanes": (
                self.processor.request_lanes
            ),
            "auto_targets_enable": (
                False
            ),
            "gamma_update_valid": (
                False
            ),
            "active_neutral_state": (
                True
            ),
            "direct_opposite_polarity_transition": (
                "forbidden"
            ),
            "mandatory_routes": [
                "-1 -> 0 -> 1",
                "1 -> 0 -> -1",
            ],
            "tick_separated_neutral_route": (
                True
            ),
            "scheduler_7_1_enabled": (
                False
            ),
            "scheduler_1_7_enabled": (
                False
            ),
            "states_before": (
                states_before
            ),
            "states_after": (
                states_after
            ),
            "phase_words_before": (
                phase_words_before
            ),
            "phase_words_after": (
                phase_words_after
            ),
            "logical_state_changes": (
                logical_changes
            ),
            "encoded_bit_toggles": (
                encoded_toggles
            ),
            "pending_route_count_before": (
                pending_before
            ),
            "pending_route_count_after": len(
                self.processor.pending_neutral_routes
            ),
            "new_route_events": [
                dict(row)
                for row in new_route_events
            ],
            "prevented_direct_events_delta": (
                self.processor.prevented_direct_events
                - prevented_before
            ),
            "neutral_routed_events_delta": (
                self.processor.neutral_routed_events
                - neutral_routed_before
            ),
            "neutralized_conflicts_delta": (
                self.processor.neutralized_conflicts
                - neutralized_before
            ),
            "actual_direct_events": (
                self.processor.actual_direct_events
            ),
            "reserved_state_events": (
                self.processor.reserved_state_events
            ),
            "queue_overflow_events": (
                self.processor.queue_overflow_events
            ),
            "event_packet_count": (
                1
            ),
            "event_packet_phase_order": list(
                EVENT_PACKET_PHASE_ORDER
            ),
            "event_totals": (
                event_totals
            ),
            "m15_trace_row": copy.deepcopy(
                dict(m15_row)
            ),
            "winner_assertions": [],
        }

        result = FRPv170StepResult(
            architecture_id=(
                ARCHITECTURE_ID
            ),
            architecture_name=(
                ARCHITECTURE_NAME
            ),
            scheduler_mode=(
                EXPECTED_SCHEDULER_MODE
            ),
            semantic_states=tuple(
                states_after
            ),
            phase_words=tuple(
                phase_words_after
            ),
            event_packets=(
                event_packets
            ),
            logical_update_metadata=(
                metadata
            ),
        )

        result_payload = (
            result.to_dict()
        )

        self.quiescence_ticks += 1

        self.quiescence_trace_sha256.append(
            result_payload[
                "adapter_step_sha256"
            ]
        )

        return result

    def snapshot(
        self,
    ) -> dict[str, Any]:
        self._assert_frp_invariants()

        payload: dict[str, Any] = {
            "schema": (
                ADAPTER_SCHEMA
            ),
            "architecture_id": (
                ARCHITECTURE_ID
            ),
            "architecture_name": (
                ARCHITECTURE_NAME
            ),
            "scheduler_mode": (
                EXPECTED_SCHEDULER_MODE
            ),
            "domain_size": (
                self.domain_size
            ),
            "domain_index": (
                self.domain_index
            ),
            "domain_seed": (
                self.domain_seed
            ),
            "nonlinearity_class": (
                self.nonlinearity_class
            ),
            "logical_updates": (
                self.logical_updates
            ),
            "quiescence_ticks": (
                self.quiescence_ticks
            ),
            "processor_ticks": (
                self.processor.tick_count
            ),
            "quiescence_started": (
                self.quiescence_started
            ),
            "semantic_states": list(
                self.processor.states
            ),
            "phase_words": list(
                self.processor.phase_words
            ),
            "event_totals": dict(
                self.event_totals
            ),
            "logical_state_changes": (
                self.logical_state_changes
            ),
            "encoded_bit_toggles": (
                self.encoded_bit_toggles
            ),
            "neutral_insertions": (
                self.neutral_insertions
            ),
            "pending_route_peak": (
                self.pending_route_peak
            ),
            "pending_route_count_final": len(
                self.processor.pending_neutral_routes
            ),
            "requested_direct_events": (
                self.processor.requested_direct_events
            ),
            "prevented_direct_events": (
                self.processor.prevented_direct_events
            ),
            "neutral_routed_events": (
                self.processor.neutral_routed_events
            ),
            "neutralized_conflicts": (
                self.processor.neutralized_conflicts
            ),
            "actual_direct_events": (
                self.processor.actual_direct_events
            ),
            "reserved_state_events": (
                self.processor.reserved_state_events
            ),
            "queue_overflow_events": (
                self.processor.queue_overflow_events
            ),
            "transition_fraction": (
                self.processor.transition_fraction
            ),
            "request_lanes": (
                self.processor.request_lanes
            ),
            "initial_preload": copy.deepcopy(
                self.initial_preload
            ),
            "step_trace_sha256": list(
                self.step_trace_sha256
            ),
            "quiescence_trace_sha256": list(
                self.quiescence_trace_sha256
            ),
            "frp_invariants_ok": (
                self.processor.actual_direct_events
                == 0
                and self.processor.reserved_state_events
                == 0
                and self.processor.queue_overflow_events
                == 0
                and self.processor.transition_fraction
                == EXPECTED_TRANSITION_FRACTION
                and self.processor.scheduler
                == EXPECTED_SCHEDULER_MODE
            ),
            "winner_assertions": [],
        }

        payload[
            "adapter_snapshot_sha256"
        ] = sha256_hex(
            canonical_json_bytes(
                payload
            )
        )

        return payload


def build_frp_v1_7_0_contract(
    profile: Mapping[str, Any],
) -> dict[str, Any]:
    validate_problem_profile(profile)

    require(
        profile.get("scheduler_mode")
        == EXPECTED_SCHEDULER_MODE,
        "initial benchmark scheduler_mode must be free",
    )

    require(
        profile.get("transition_fraction")
        == EXPECTED_TRANSITION_FRACTION,
        "transition_fraction must remain 0.25",
    )

    require(
        profile.get("auto_targets_enable")
        is True,
        "auto_targets_enable must remain true",
    )

    payload: dict[str, Any] = {
        "schema": (
            CONTRACT_SCHEMA
        ),
        "architecture_id": (
            ARCHITECTURE_ID
        ),
        "architecture_name": (
            ARCHITECTURE_NAME
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "frp_reference": {
            "version": VERSION,
            "milestone": MILESTONE,
            "source_file": (
                "frp_prototype_v1_7_0.py"
            ),
            "source_sha256": (
                FRP_SOURCE_SHA256
            ),
            "processor_class": (
                "QuantizedReferenceShadowProcessor"
            ),
            "kernel_import_rule": (
                "import_existing_kernel_without_duplication"
            ),
        },
        "execution_model": (
            "stateful fixed-point feedback"
        ),
        "semantic_output_domain": [
            -1,
            0,
            1,
        ],
        "phase_output_domain": (
            "PHASE_U32"
        ),
        "state_encoding": {
            "-1": "2'b11",
            "0": "2'b00",
            "+1": "2'b01",
            "reserved": "2'b10",
        },
        "active_neutral_state": (
            True
        ),
        "direct_opposite_polarity_transition": (
            "forbidden"
        ),
        "mandatory_routes": [
            "-1 -> 0 -> 1",
            "1 -> 0 -> -1",
        ],
        "tick_separated_neutral_route": (
            True
        ),
        "terminal_quiescence": {
            "enabled": True,
            "terminal_only": True,
            "auto_targets_enable": False,
            "transition_requests": "empty",
            "gamma_update_valid": False,
            "advances_logical_workload": False,
            "emits_accounted_event_packet": True,
            "completion_condition": (
                "pending_neutral_routes == 0"
            ),
        },
        "transition_fraction": (
            EXPECTED_TRANSITION_FRACTION
        ),
        "auto_targets_enable": (
            True
        ),
        "scheduler_7_1_enabled": (
            False
        ),
        "scheduler_1_7_enabled": (
            False
        ),
        "shared_workload_parameter_mapping": {
            "cells": (
                "domain_size"
            ),
            "seed": (
                "domain_seed"
            ),
            "fractal_alpha": (
                "shared_problem_model.fractal_alpha"
            ),
            "thermal_beta": (
                "shared_problem_model.thermal_beta"
            ),
            "ambient_heat": (
                "shared_problem_model.ambient_heat"
            ),
            "thermal_time_constant": (
                "shared_problem_model."
                "thermal_time_constant"
            ),
            "thermal_soft_limit": (
                "shared_problem_model."
                "thermal_soft_limit"
            ),
            "thermal_hard_limit": (
                "shared_problem_model."
                "thermal_hard_limit"
            ),
            "thermal_diffusion_gain": (
                "shared_problem_model."
                "thermal_diffusion_gain"
            ),
            "coupling_nominal": (
                "nonlinearity_classes[class]."
                "coupling_nominal"
            ),
            "gamma_nominal": (
                "nonlinearity_classes[class]."
                "gamma_nominal_radians"
            ),
            "delay_alpha": (
                "nonlinearity_classes[class]."
                "delay_alpha"
            ),
        },
        "deterministic_preload_mapping": {
            "states": (
                "initial_states"
            ),
            "phase_words": (
                "initial_phase_words"
            ),
            "base_frequency_q16": (
                "initial_frequency_target_q16"
            ),
            "frequency_target_q16": (
                "initial_frequency_target_q16"
            ),
            "frequency_current_q16": (
                "initial_frequency_current_q16"
            ),
            "heat_q16": (
                "initial_heat_q16"
            ),
            "pending_neutral_routes": (
                "empty"
            ),
        },
        "gamma_target_rule": (
            "the same deterministic per-domain per-tick "
            "Q16 gamma target vector is supplied with "
            "gamma_update_valid=true"
        ),
        "event_packet_phase_order": list(
            EVENT_PACKET_PHASE_ORDER
        ),
        "event_accounting_profile": (
            EVENT_ACCOUNTING_PROFILE
        ),
        "event_accounting_contracts_by_domain_size": {
            str(cells): _event_accounting_contract(
                cells=cells,
                hierarchy_depth=(
                    cells.bit_length() - 1
                ),
                request_lanes=max(
                    1,
                    int(
                        round(
                            cells
                            * EXPECTED_TRANSITION_FRACTION
                        )
                    ),
                ),
            )
            for cells
            in (
                8,
                16,
                32,
            )
        },
        "event_accounting_parameterization_rule": (
            "cells, hierarchy_depth, and request_lanes "
            "are derived from each actual M15 domain "
            "instance"
        ),
        "external_thermal_ceiling_applied_here": (
            False
        ),
        "convergence_tracking_applied_here": (
            False
        ),
        "kernel_duplicated": (
            False
        ),
        "winner_assertions": [],
    }

    payload[
        "frp_v1_7_0_contract_sha256"
    ] = sha256_hex(
        canonical_json_bytes(
            payload
        )
    )

    return payload


def _synthetic_initialization(
) -> Any:
    class SyntheticInitialization:
        domain_size = 8

        domain_index = 0

        domain_seed = 76

        nonlinearity_class = (
            "medium"
        )

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
            % PHASE_MOD
            for index
            in range(
                8
            )
        )

        initial_frequency_target_q16 = tuple(
            1
            << 16
            for _ in range(
                8
            )
        )

        initial_frequency_current_q16 = tuple(
            1
            << 16
            for _ in range(
                8
            )
        )

        initial_heat_q16 = tuple(
            3277
            for _ in range(
                8
            )
        )

    return (
        SyntheticInitialization()
    )


def _forced_route_initialization(
) -> Any:
    class ForcedRouteInitialization:
        domain_size = 8

        domain_index = 0

        domain_seed = 7601

        nonlinearity_class = (
            "medium"
        )

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

        initial_phase_words = (
            PHASE_MOD
            // 4,
            0,
            PHASE_MOD
            // 4,
            3
            * PHASE_MOD
            // 4,
            0,
            PHASE_MOD
            // 4,
            3
            * PHASE_MOD
            // 4,
            0,
        )

        initial_frequency_target_q16 = tuple(
            1
            << 16
            for _ in range(
                8
            )
        )

        initial_frequency_current_q16 = tuple(
            1
            << 16
            for _ in range(
                8
            )
        )

        initial_heat_q16 = tuple(
            3277
            for _ in range(
                8
            )
        )

    return (
        ForcedRouteInitialization()
    )


def _self_test_gamma_targets(
    tick: int,
    size: int,
) -> tuple[int, ...]:
    scale = 3277

    span = (
        2
        * scale
        + 1
    )

    values = []

    for cell_index in range(
        size
    ):
        digest = hashlib.sha256(
            (
                f"frp-v1-7-0-adapter-self-test:"
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
            byteorder="big",
            signed=False,
        )

        values.append(
            (
                raw
                % span
            )
            - scale
        )

    return tuple(
        values
    )


def run_self_test(
    profile: Mapping[str, Any] | None = None,
) -> dict[str, Any]:
    if profile is None:
        require(
            WORKLOAD_PROFILE_PATH.is_file(),
            "canonical nonlinear multitask workload profile not found",
        )

        try:
            loaded_profile = json.loads(
                WORKLOAD_PROFILE_PATH.read_text(
                    encoding="utf-8"
                )
            )
        except (
            OSError,
            json.JSONDecodeError,
        ) as exc:
            fail(
                "unable to load canonical nonlinear multitask "
                f"workload profile: {exc}"
            )

        require(
            isinstance(loaded_profile, dict),
            "canonical workload profile root must be an object",
        )

        profile = loaded_profile

    validate_problem_profile(
        profile
    )

    require(
        FRP_SOURCE_SHA256
        == EXPECTED_FRP_SOURCE_SHA256,
        "source binding failed",
    )

    forced = (
        FRPv170NonlinearMultitaskAdapter(
            profile,
            _forced_route_initialization(),
        )
    )

    zero_gamma = tuple(
        0
        for _ in range(
            forced.domain_size
        )
    )

    forced_first = forced.step(
        gamma_targets_q16=(
            zero_gamma
        )
    )

    require(
        forced_first.semantic_states[
            0
        ]
        == 0,
        "forced opposite-polarity request did not "
        "enter active neutral state",
    )

    require(
        forced.processor.prevented_direct_events
        >= 1,
        "forced opposite-polarity route "
        "was not prevented",
    )

    require(
        forced.processor.neutral_routed_events
        >= 1,
        "forced opposite-polarity route "
        "was not neutral-routed",
    )

    require(
        len(
            forced.processor.pending_neutral_routes
        )
        >= 1,
        "forced neutral route did not remain "
        "tick-separated",
    )

    require(
        forced.processor.actual_direct_events
        == 0,
        "forced route created a direct "
        "opposite-polarity transition",
    )

    forced_quiescence = (
        forced.quiescence_step()
    )

    require(
        forced.processor.actual_direct_events
        == 0,
        "tick-separated route created a direct "
        "opposite-polarity transition",
    )

    require(
        len(
            forced.processor.pending_neutral_routes
        )
        == 0,
        "terminal quiescence did not drain the "
        "forced pending neutral route",
    )

    require(
        forced.logical_updates
        == 1,
        "terminal quiescence advanced the logical workload",
    )

    require(
        forced.quiescence_ticks
        == 1,
        "terminal quiescence tick count mismatch",
    )

    require(
        forced.processor.tick_count
        == 2,
        "M15 processor tick count did not include quiescence",
    )

    require(
        forced_quiescence.logical_update_metadata[
            "step_kind"
        ]
        == "terminal_quiescence",
        "terminal quiescence metadata kind mismatch",
    )

    require(
        forced_quiescence.logical_update_metadata[
            "advances_logical_workload"
        ]
        is False,
        "terminal quiescence metadata advanced the workload",
    )

    require(
        forced_quiescence.logical_update_metadata[
            "auto_targets_enable"
        ]
        is False,
        "terminal quiescence re-enabled automatic targets",
    )

    require(
        forced_quiescence.logical_update_metadata[
            "pending_route_count_after"
        ]
        == 0,
        "terminal quiescence metadata retained a pending route",
    )

    first = (
        FRPv170NonlinearMultitaskAdapter(
            profile,
            _synthetic_initialization(),
        )
    )

    second = (
        FRPv170NonlinearMultitaskAdapter(
            profile,
            _synthetic_initialization(),
        )
    )

    trace_a: list[
        dict[str, Any]
    ] = []

    trace_b: list[
        dict[str, Any]
    ] = []

    for tick in range(
        16
    ):
        gamma_targets = (
            _self_test_gamma_targets(
                tick,
                first.domain_size,
            )
        )

        result_a = first.step(
            gamma_targets_q16=(
                gamma_targets
            )
        )

        result_b = second.step(
            gamma_targets_q16=(
                gamma_targets
            )
        )

        payload_a = (
            result_a.to_dict()
        )

        payload_b = (
            result_b.to_dict()
        )

        require(
            payload_a
            == payload_b,
            "repeated M15 adapter execution "
            "is not deterministic",
        )

        require(
            len(
                result_a.event_packets
            )
            == 1,
            "M15 adapter must emit exactly one "
            "event packet per processor tick",
        )

        require(
            set(
                result_a.event_packets[
                    0
                ]
            )
            == set(
                EVENT_FIELDS
            ),
            "M15 event packet field set mismatch",
        )

        require(
            result_a.logical_update_metadata[
                "actual_direct_events"
            ]
            == 0,
            "M15 self-test observed an actual "
            "direct transition",
        )

        require(
            result_a.logical_update_metadata[
                "reserved_state_events"
            ]
            == 0,
            "M15 self-test observed a reserved state",
        )

        require(
            result_a.logical_update_metadata[
                "queue_overflow_events"
            ]
            == 0,
            "M15 self-test observed queue overflow",
        )

        require(
            all(
                state in TERNARY_STATES
                for state
                in result_a.semantic_states
            ),
            "M15 self-test escaped {-1, 0, 1}",
        )

        require(
            all(
                0
                <= word
                < PHASE_MOD
                for word
                in result_a.phase_words
            ),
            "M15 self-test escaped PHASE_U32",
        )

        trace_a.append(
            payload_a
        )

        trace_b.append(
            payload_b
        )

    require(
        trace_a
        == trace_b,
        "repeated M15 adapter traces differ",
    )

    snapshot_a = (
        first.snapshot()
    )

    snapshot_b = (
        second.snapshot()
    )

    require(
        snapshot_a
        == snapshot_b,
        "repeated M15 adapter snapshots differ",
    )

    require(
        snapshot_a[
            "logical_updates"
        ]
        == 16,
        "logical update count mismatch",
    )

    require(
        snapshot_a[
            "frp_invariants_ok"
        ]
        is True,
        "FRP invariants failed",
    )

    contract_a = (
        build_frp_v1_7_0_contract(
            profile
        )
    )

    contract_b = (
        build_frp_v1_7_0_contract(
            profile
        )
    )

    require(
        contract_a
        == contract_b,
        "FRP adapter contract is not deterministic",
    )

    return {
        "schema": (
            SELF_TEST_SCHEMA
        ),
        "status": (
            "PASS"
        ),
        "architecture_id": (
            ARCHITECTURE_ID
        ),
        "scheduler_mode": (
            EXPECTED_SCHEDULER_MODE
        ),
        "logical_updates": (
            snapshot_a[
                "logical_updates"
            ]
        ),
        "event_packet_count_per_update": (
            1
        ),
        "frp_source_sha256": (
            FRP_SOURCE_SHA256
        ),
        "processor_class": (
            "QuantizedReferenceShadowProcessor"
        ),
        "forced_route_prevented_direct_events": (
            forced.processor.prevented_direct_events
        ),
        "forced_route_neutral_routed_events": (
            forced.processor.neutral_routed_events
        ),
        "forced_route_quiescence_ticks": (
            forced.quiescence_ticks
        ),
        "forced_route_pending_final": len(
            forced.processor.pending_neutral_routes
        ),
        "actual_direct_events": (
            snapshot_a[
                "actual_direct_events"
            ]
        ),
        "reserved_state_events": (
            snapshot_a[
                "reserved_state_events"
            ]
        ),
        "queue_overflow_events": (
            snapshot_a[
                "queue_overflow_events"
            ]
        ),
        "trace_sha256": (
            sha256_hex(
                canonical_json_bytes(
                    trace_a
                )
            )
        ),
        "adapter_snapshot_sha256": (
            snapshot_a[
                "adapter_snapshot_sha256"
            ]
        ),
        "frp_v1_7_0_contract_sha256": (
            contract_a[
                "frp_v1_7_0_contract_sha256"
            ]
        ),
        "kernel_duplicated": (
            False
        ),
        "winner_assertions": [],
    }

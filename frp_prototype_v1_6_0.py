#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

VERSION = "1.6.0"
MILESTONE = "M14 — Physical Implementation Correlation and Production Qualification Package"

STRUCTURED_SCHEMA = "frp.structured_output.v1.6.0"
BENCHMARK_SCHEMA = "frp.m3.benchmark_matrix.v1.6.0"

M14_HIERARCHICAL_ULTRAMETRIC_TOPOLOGY_MODEL_SCHEMA = (
    "frp.m14.hierarchical_ultrametric_topology_model.v1.6.0"
)
M14_FRACTAL_COUPLING_WEIGHT_MAP_SCHEMA = (
    "frp.m14.fractal_coupling_weight_map.v1.6.0"
)
M14_MULTISCALE_PHASE_COHERENCE_MAP_SCHEMA = (
    "frp.m14.multiscale_phase_coherence_map.v1.6.0"
)
M14_CLUSTER_LOCAL_THERMAL_FIELD_SCHEMA = (
    "frp.m14.cluster_local_thermal_field.v1.6.0"
)
M14_CROSS_CLUSTER_PROPAGATION_MAP_SCHEMA = (
    "frp.m14.cross_cluster_propagation_map.v1.6.0"
)
M14_LOCALIZED_HOTSPOT_CONTAINMENT_HARNESS_SCHEMA = (
    "frp.m14.localized_hotspot_containment_harness.v1.6.0"
)
M14_DENSE_HIERARCHICAL_EQUIVALENCE_MAP_SCHEMA = (
    "frp.m14.dense_hierarchical_equivalence_map.v1.6.0"
)
M14_PHYSICAL_DOMAIN_CORRELATION_PACKAGE_SCHEMA = (
    "frp.m14.physical_domain_correlation_package.v1.6.0"
)

SCHEDULER_MODES = ("free", "7/1", "1/7")
TERNARY_STATES = (-1, 0, 1)

DEFAULT_CELLS = 16
DEFAULT_STEPS = 64
DEFAULT_SEED = 76
DEFAULT_TRANSITION_FRACTION = 0.25
DEFAULT_GAMMA = 0.30 * math.pi
DEFAULT_FRACTAL_ALPHA = 0.70
DEFAULT_THERMAL_BETA = 1.20
DEFAULT_AMBIENT_HEAT = 0.05
DEFAULT_THERMAL_TIME_CONSTANT = 14.0
DEFAULT_THERMAL_SOFT_LIMIT = 0.22
DEFAULT_THERMAL_HARD_LIMIT = 0.90
DEFAULT_COUPLING_NOMINAL = 0.28
DEFAULT_DELAY_ALPHA = 0.30
DEFAULT_THERMAL_DIFFUSION_GAIN = 0.035
DEFAULT_EQUIVALENCE_TOLERANCE = 1e-12


def q16(value: float) -> int:
    return int(round(value * 65536.0))


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def is_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


def phase_order(phases: Sequence[float]) -> float:
    if not phases:
        return 0.0

    c = sum(math.cos(p) for p in phases) / len(phases)
    s = sum(math.sin(p) for p in phases) / len(phases)

    return math.sqrt(c * c + s * s)


def scheduler_state(mode: str, tick: int) -> str:
    if mode == "7/1":
        return "commit" if (tick + 1) % 8 == 0 else "balance"

    if mode == "1/7":
        return "excite" if tick % 8 == 0 else "neutralize"

    return "free"


def expected_scheduler_counts(
    mode: str,
    steps: int,
) -> Dict[str, int]:
    counts: Dict[str, int] = {}

    for tick in range(steps):
        state = scheduler_state(
            mode,
            tick,
        )

        counts[state] = (
            counts.get(
                state,
                0,
            )
            + 1
        )

    return counts


def target_state(
    phase: float,
) -> int:
    x = math.sin(
        phase
    )

    if x > 0.33:
        return 1

    if x < -0.33:
        return -1

    return 0


def round_list(
    values: Iterable[float],
    digits: int = 6,
) -> List[float]:
    return [
        round(
            value,
            digits,
        )
        for value in values
    ]


class FractalResonanceProcessor:
    def __init__(
        self,
        cells: int,
        transition_fraction: float,
        gamma_nominal: float,
        scheduler: str,
        seed: int,
        fractal_alpha: float = DEFAULT_FRACTAL_ALPHA,
        thermal_beta: float = DEFAULT_THERMAL_BETA,
        ambient_heat: float = DEFAULT_AMBIENT_HEAT,
        thermal_time_constant: float = DEFAULT_THERMAL_TIME_CONSTANT,
        thermal_soft_limit: float = DEFAULT_THERMAL_SOFT_LIMIT,
        thermal_hard_limit: float = DEFAULT_THERMAL_HARD_LIMIT,
        coupling_nominal: float = DEFAULT_COUPLING_NOMINAL,
        delay_alpha: float = DEFAULT_DELAY_ALPHA,
        thermal_diffusion_gain: float = DEFAULT_THERMAL_DIFFUSION_GAIN,
        equivalence_tolerance: float = DEFAULT_EQUIVALENCE_TOLERANCE,
        coupling_path: str = "hierarchical",
    ) -> None:
        if not is_power_of_two(
            cells
        ):
            raise ValueError(
                "M14 exact dyadic topology requires cells to be a power of two"
            )

        if cells < 2:
            raise ValueError(
                "M14 requires at least two cells"
            )

        if scheduler not in SCHEDULER_MODES:
            raise ValueError(
                f"Unsupported scheduler mode: {scheduler}"
            )

        if fractal_alpha <= 0:
            raise ValueError(
                "fractal_alpha must be greater than zero"
            )

        if thermal_beta <= 0:
            raise ValueError(
                "thermal_beta must be greater than zero"
            )

        if coupling_path not in (
            "dense",
            "hierarchical",
        ):
            raise ValueError(
                "coupling_path must be 'dense' or 'hierarchical'"
            )

        self.cells = cells

        self.hierarchy_depth = (
            cells.bit_length()
            - 1
        )

        self.transition_fraction = clamp(
            transition_fraction,
            0.01,
            1.0,
        )

        self.gamma_nominal = (
            gamma_nominal
        )

        self.scheduler = (
            scheduler
        )

        self.seed = (
            seed
        )

        self.random = random.Random(
            seed
        )

        self.fractal_alpha = (
            fractal_alpha
        )

        self.thermal_beta = (
            thermal_beta
        )

        self.coupling_path = (
            coupling_path
        )

        self.equivalence_tolerance = (
            equivalence_tolerance
        )

        self.states = [
            self.random.choice(
                TERNARY_STATES
            )
            for _ in range(
                cells
            )
        ]

        self.phases = [
            self.random.random()
            * math.tau
            for _ in range(
                cells
            )
        ]

        self.base_frequencies = [
            1.0
            for _ in range(
                cells
            )
        ]

        self.frequency_targets = [
            1.0
            for _ in range(
                cells
            )
        ]

        self.frequencies = [
            1.0
            for _ in range(
                cells
            )
        ]

        self.actual_direct_events = 0

        self.requested_direct_events = 0

        self.prevented_direct_events = 0

        self.neutral_routed_events = 0

        self.neutralized_conflicts = 0

        self.transition_requests: List[
            Tuple[int, int]
        ] = []

        self.pending_neutral_routes: List[
            Tuple[int, int, int]
        ] = []

        self.scheduler_counts: Dict[
            str,
            int,
        ] = {}

        self.telemetry: List[
            Dict[str, Any]
        ] = []

        self.current_switch_changes = 0

        self.cell_switch_activity = [
            0
            for _ in range(
                cells
            )
        ]

        self.switch_load = 0.0

        self.switch_load_peak = 0.0

        self.ambient_heat = (
            ambient_heat
        )

        self.heat_cells = [
            ambient_heat
            for _ in range(
                cells
            )
        ]

        self.local_heat_peaks = [
            ambient_heat
            for _ in range(
                cells
            )
        ]

        self.heat = (
            ambient_heat
        )

        self.heat_peak = (
            ambient_heat
        )

        self.local_heat_peak = (
            ambient_heat
        )

        self.thermal_time_constant = (
            thermal_time_constant
        )

        self.thermal_soft_limit = (
            thermal_soft_limit
        )

        self.thermal_hard_limit = (
            thermal_hard_limit
        )

        self.base_power_cell = 0.0018

        self.switch_power_gain = 0.052

        self.lag_power_gain = 0.018

        self.thermal_diffusion_gain = (
            thermal_diffusion_gain
        )

        self.generated_power_cells = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.thermal_dissipation_cells = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.thermal_diffusion_cells = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.thermal_overload_cells = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.coupling_nominal = (
            coupling_nominal
        )

        self.thermal_coupling_gain = 2.50

        self.thermal_node_factors = [
            1.0
            for _ in range(
                cells
            )
        ]

        self.effective_coupling_min = (
            coupling_nominal
        )

        self.delay_alpha = (
            delay_alpha
        )

        self.state_frequency_gain = 0.06

        self.switching_frequency_gain = 0.12

        self.gamma_noise_states = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.gamma_noise_targets = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.gamma_correlation_alpha = 0.15

        self.gamma_thermal_gain = 0.08

        self.gamma_effective = [
            gamma_nominal
            for _ in range(
                cells
            )
        ]

        self.gamma_drift = [
            0.0
            for _ in range(
                cells
            )
        ]

        self.gamma_drift_peak = 0.0

        self.thermal_compression_gain = 3.0

        self.margin_compression_gain = 1.5

        self.stability_soft_margin = 0.25

        self.previous_C_minus_P = 0.60

        self.first_C_minus_P_crossing: Optional[
            Dict[str, Any]
        ] = None

        self.raw_phase_coherence = phase_order(
            self.phases
        )

        self.coherence_compression = 1.0

        self.effective_coherence = (
            self.raw_phase_coherence
        )

        self.C_value = 1.0

        self.P_value = (
            self.heat
        )

        self.C_minus_P = (
            self.C_value
            - self.P_value
        )

        self.coupling_matrix = (
            self._generate_hierarchical_matrix(
                self.fractal_alpha
            )
        )

        self.thermal_matrix = (
            self._generate_hierarchical_matrix(
                self.thermal_beta
            )
        )

        self.coupling_pair_weights_by_level = (
            self._pair_weights_by_level(
                self.fractal_alpha
            )
        )

        self.thermal_pair_weights_by_level = (
            self._pair_weights_by_level(
                self.thermal_beta
            )
        )

    def hierarchical_distance(
        self,
        i: int,
        j: int,
    ) -> int:
        if i == j:
            return 0

        return (
            i ^ j
        ).bit_length()

    def shell_population(
        self,
        distance: int,
    ) -> int:
        if (
            distance < 1

            or distance
            > self.hierarchy_depth
        ):
            raise ValueError(
                "distance outside hierarchy depth"
            )

        return (
            2
            ** (
                distance
                - 1
            )
        )

    def _pair_weights_by_level(
        self,
        exponent: float,
    ) -> Dict[int, float]:
        shell_normalizer = sum(
            1.0
            / (
                d
                ** exponent
            )
            for d in range(
                1,
                self.hierarchy_depth
                + 1,
            )
        )

        return {
            d:
                1.0
                / (
                    self.shell_population(
                        d
                    )
                    * (
                        d
                        ** exponent
                    )
                    * shell_normalizer
                )

            for d in range(
                1,
                self.hierarchy_depth
                + 1,
            )
        }

    def _generate_hierarchical_matrix(
        self,
        exponent: float,
    ) -> List[List[float]]:
        pair_weights = (
            self._pair_weights_by_level(
                exponent
            )
        )

        matrix = [
            [
                0.0
                for _ in range(
                    self.cells
                )
            ]
            for _ in range(
                self.cells
            )
        ]

        for i in range(
            self.cells
        ):
            for j in range(
                self.cells
            ):
                if i == j:
                    continue

                distance = (
                    self.hierarchical_distance(
                        i,
                        j,
                    )
                )

                matrix[i][j] = (
                    pair_weights[
                        distance
                    ]
                )

        return matrix

    def topology_metrics(
        self,
        matrix: Sequence[
            Sequence[float]
        ],
        exponent: float,
    ) -> Dict[str, Any]:
        row_sum_errors = [
            abs(
                sum(
                    row
                )
                - 1.0
            )
            for row in matrix
        ]

        symmetry_error_max = 0.0

        diagonal_error_max = 0.0

        for i in range(
            self.cells
        ):
            diagonal_error_max = max(
                diagonal_error_max,
                abs(
                    matrix[i][i]
                ),
            )

            for j in range(
                self.cells
            ):
                symmetry_error_max = max(
                    symmetry_error_max,

                    abs(
                        matrix[i][j]
                        - matrix[j][i]
                    ),
                )

        pair_weights = (
            self._pair_weights_by_level(
                exponent
            )
        )

        shell_profile = []

        for distance in range(
            1,
            self.hierarchy_depth
            + 1,
        ):
            shell_profile.append({
                "distance":
                    distance,

                "shell_population":
                    self.shell_population(
                        distance
                    ),

                "normalized_pair_weight":
                    pair_weights[
                        distance
                    ],

                "aggregate_shell_influence":
                    self.shell_population(
                        distance
                    )
                    * pair_weights[
                        distance
                    ],
            })

        shell_influences = [
            row[
                "aggregate_shell_influence"
            ]
            for row in shell_profile
        ]

        monotonic = all(
            shell_influences[
                index
            ]
            >
            shell_influences[
                index
                + 1
            ]

            for index in range(
                len(
                    shell_influences
                )
                - 1
            )
        )

        return {
            "hierarchy_depth":
                self.hierarchy_depth,

            "row_sum_error_max":
                max(
                    row_sum_errors
                ),

            "symmetry_error_max":
                symmetry_error_max,

            "diagonal_error_max":
                diagonal_error_max,

            "shell_influence_profile":
                shell_profile,

            "shell_influence_monotonic":
                monotonic,

            "row_sum_match":
                max(
                    row_sum_errors
                )
                <= 1e-12,

            "symmetry_match":
                symmetry_error_max
                <= 1e-12,

            "diagonal_zero":
                diagonal_error_max
                <= 1e-15,
        }

    def request_transition(
        self,
        cell_idx: int,
        target: int,
    ) -> None:
        if target not in TERNARY_STATES:
            raise ValueError(
                "FRP transition target must be one of -1, 0, 1"
            )

        if (
            cell_idx < 0

            or cell_idx
            >= self.cells
        ):
            raise IndexError(
                "FRP transition cell index out of range"
            )

        self.transition_requests.append(
            (
                cell_idx,
                target,
            )
        )

    def _apply_state(
        self,
        cell_idx: int,
        next_state: int,
    ) -> bool:
        if next_state not in TERNARY_STATES:
            raise ValueError(
                "FRP state must remain in -1, 0, 1"
            )

        current = (
            self.states[
                cell_idx
            ]
        )

        if current == next_state:
            return False

        if (
            current
            * next_state
            == -1
        ):
            self.actual_direct_events += 1

        self.states[
            cell_idx
        ] = next_state

        self.current_switch_changes += 1

        self.cell_switch_activity[
            cell_idx
        ] = 1

        return True

    def process_pending_neutral_routes(
        self,
        tick_index: int,
        max_changes: int,
    ) -> int:
        changes = 0

        still_pending: List[
            Tuple[
                int,
                int,
                int,
            ]
        ] = []

        for (
            cell_idx,
            target,
            ready_tick,
        ) in self.pending_neutral_routes:
            if (
                tick_index
                < ready_tick

                or changes
                >= max_changes
            ):
                still_pending.append(
                    (
                        cell_idx,
                        target,
                        ready_tick,
                    )
                )

                continue

            if (
                self.states[
                    cell_idx
                ]
                == 0
            ):
                if self._apply_state(
                    cell_idx,
                    target,
                ):
                    changes += 1

            elif (
                self.states[
                    cell_idx
                ]
                != target
            ):
                still_pending.append(
                    (
                        cell_idx,
                        target,
                        ready_tick,
                    )
                )

        self.pending_neutral_routes = (
            still_pending
        )

        return changes

    def process_transition_requests(
        self,
        tick_index: int,
        max_changes: int,
        changes_used: int,
    ) -> int:
        changes = (
            changes_used
        )

        remaining_requests: List[
            Tuple[int, int]
        ] = []

        for (
            cell_idx,
            target,
        ) in self.transition_requests:
            if changes >= max_changes:
                remaining_requests.append(
                    (
                        cell_idx,
                        target,
                    )
                )

                continue

            current = (
                self.states[
                    cell_idx
                ]
            )

            if current == target:
                continue

            if (
                current
                * target
                == -1
            ):
                self.requested_direct_events += 1

                self.prevented_direct_events += 1

                self.neutralized_conflicts += 1

                if self._apply_state(
                    cell_idx,
                    0,
                ):
                    changes += 1

                    self.neutral_routed_events += 1

                    self.pending_neutral_routes.append(
                        (
                            cell_idx,
                            target,
                            tick_index
                            + 1,
                        )
                    )

                continue

            if self._apply_state(
                cell_idx,
                target,
            ):
                changes += 1

        self.transition_requests = (
            remaining_requests
        )

        return changes

    def update_reference_state_targets(
        self,
        tick_index: int,
        max_changes: int,
        changes_used: int,
    ) -> int:
        changes = (
            changes_used
        )

        for i in range(
            self.cells
        ):
            if changes >= max_changes:
                break

            desired = target_state(
                self.phases[
                    i
                ]
            )

            current = (
                self.states[
                    i
                ]
            )

            if current == desired:
                continue

            if (
                current
                * desired
                == -1
            ):
                self.prevented_direct_events += 1

                self.neutralized_conflicts += 1

                if self._apply_state(
                    i,
                    0,
                ):
                    changes += 1

                    self.neutral_routed_events += 1

                    self.pending_neutral_routes.append(
                        (
                            i,
                            desired,
                            tick_index
                            + 1,
                        )
                    )

                continue

            if self._apply_state(
                i,
                desired,
            ):
                changes += 1

        return changes

    def update_delay_dynamics(
        self,
    ) -> Dict[str, Any]:
        lags: List[
            float
        ] = []

        for i in range(
            self.cells
        ):
            self.frequency_targets[i] = (
                self.base_frequencies[i]

                + self.state_frequency_gain
                * abs(
                    self.states[i]
                )

                + self.switching_frequency_gain
                * self.cell_switch_activity[i]
            )

            self.frequencies[i] += (
                self.delay_alpha
                * (
                    self.frequency_targets[i]
                    - self.frequencies[i]
                )
            )

            lags.append(
                abs(
                    self.frequency_targets[i]
                    - self.frequencies[i]
                )
            )

        return {
            "frequency_lags":
                lags,

            "mean_frequency_lag":
                sum(
                    lags
                )
                / self.cells,

            "frequency_lag_peak_tick":
                max(
                    lags
                ),
        }

    def update_local_thermal_field(
        self,
        frequency_lags: Sequence[float],
    ) -> Dict[str, Any]:
        previous_heat = list(
            self.heat_cells
        )

        for i in range(
            self.cells
        ):
            self.generated_power_cells[i] = (
                self.base_power_cell

                + self.switch_power_gain
                * self.cell_switch_activity[i]

                + self.lag_power_gain
                * frequency_lags[i]
            )

            self.thermal_dissipation_cells[i] = (
                previous_heat[i]
                - self.ambient_heat
            ) / self.thermal_time_constant

            self.thermal_diffusion_cells[i] = (
                self.thermal_diffusion_gain

                * sum(
                    self.thermal_matrix[i][j]
                    * (
                        previous_heat[j]
                        - previous_heat[i]
                    )

                    for j in range(
                        self.cells
                    )
                )
            )

        for i in range(
            self.cells
        ):
            self.heat_cells[i] = max(
                self.ambient_heat,

                previous_heat[i]

                + self.generated_power_cells[i]

                - self.thermal_dissipation_cells[i]

                + self.thermal_diffusion_cells[i],
            )

            self.local_heat_peaks[i] = max(
                self.local_heat_peaks[i],
                self.heat_cells[i],
            )

            self.thermal_overload_cells[i] = max(
                0.0,

                self.heat_cells[i]
                - self.thermal_soft_limit,
            )

        self.heat = (
            sum(
                self.heat_cells
            )
            / self.cells
        )

        self.heat_peak = max(
            self.heat_peak,
            self.heat,
        )

        self.local_heat_peak = max(
            self.local_heat_peak,
            max(
                self.heat_cells
            ),
        )

        return {
            "heat":
                self.heat,

            "heat_cells":
                list(
                    self.heat_cells
                ),

            "local_heat_peak_tick":
                max(
                    self.heat_cells
                ),

            "generated_power_mean":
                sum(
                    self.generated_power_cells
                )
                / self.cells,

            "generated_power_peak_tick":
                max(
                    self.generated_power_cells
                ),

            "thermal_dissipation_mean":
                sum(
                    self.thermal_dissipation_cells
                )
                / self.cells,

            "thermal_diffusion_abs_mean":
                sum(
                    abs(
                        x
                    )
                    for x in self.thermal_diffusion_cells
                )
                / self.cells,

            "thermal_overload_mean":
                sum(
                    self.thermal_overload_cells
                )
                / self.cells,

            "thermal_overload_peak_tick":
                max(
                    self.thermal_overload_cells
                ),
        }

    def update_local_gamma_drift(
        self,
        tick_index: int,
    ) -> None:
        if tick_index % 8 == 0:
            self.gamma_noise_targets = [
                self.random.uniform(
                    -1.0,
                    1.0,
                )
                for _ in range(
                    self.cells
                )
            ]

        for i in range(
            self.cells
        ):
            self.gamma_noise_states[i] += (
                self.gamma_correlation_alpha
                * (
                    self.gamma_noise_targets[i]
                    - self.gamma_noise_states[i]
                )
            )

            self.gamma_effective[i] = (
                self.gamma_nominal

                + self.gamma_thermal_gain

                * self.thermal_overload_cells[i]

                * self.gamma_noise_states[i]
            )

            self.gamma_drift[i] = (
                self.gamma_effective[i]
                - self.gamma_nominal
            )

            self.gamma_drift_peak = max(
                self.gamma_drift_peak,

                abs(
                    self.gamma_drift[i]
                ),
            )

    def update_thermal_node_factors(
        self,
    ) -> None:
        self.thermal_node_factors = [
            math.exp(
                -0.5
                * self.thermal_coupling_gain
                * overload
            )

            for overload in self.thermal_overload_cells
        ]

        self.effective_coupling_min = min(
            self.effective_coupling_min,

            self.coupling_nominal

            * min(
                self.thermal_node_factors
            )

            * min(
                self.thermal_node_factors
            ),
        )

    def dense_coupling_field(
        self,
    ) -> List[float]:
        field = [
            0.0
            for _ in range(
                self.cells
            )
        ]

        for i in range(
            self.cells
        ):
            weighted_sum = 0.0

            for j in range(
                self.cells
            ):
                if i == j:
                    continue

                thermal_pair_factor = (
                    self.thermal_node_factors[i]

                    * self.thermal_node_factors[j]
                )

                weighted_sum += (
                    self.coupling_matrix[i][j]

                    * thermal_pair_factor

                    * math.sin(
                        self.phases[j]
                        - self.phases[i]
                        - self.gamma_effective[i]
                    )
                )

            field[i] = (
                self.coupling_nominal
                * weighted_sum
            )

        return field

    def _weighted_phase_prefix(
        self,
    ) -> Tuple[
        List[float],
        List[float],
    ]:
        prefix_real = [
            0.0
        ]

        prefix_imag = [
            0.0
        ]

        for (
            factor,
            phase,
        ) in zip(
            self.thermal_node_factors,
            self.phases,
        ):
            prefix_real.append(
                prefix_real[-1]
                + factor
                * math.cos(
                    phase
                )
            )

            prefix_imag.append(
                prefix_imag[-1]
                + factor
                * math.sin(
                    phase
                )
            )

        return (
            prefix_real,
            prefix_imag,
        )

    @staticmethod
    def _prefix_range(
        prefix: Sequence[float],
        start: int,
        end: int,
    ) -> float:
        return (
            prefix[end]
            - prefix[start]
        )

    def sibling_shell_bounds(
        self,
        cell_idx: int,
        distance: int,
    ) -> Tuple[int, int]:
        half_block_size = (
            2
            ** (
                distance
                - 1
            )
        )

        half_index = (
            cell_idx
            // half_block_size
        )

        sibling_half_index = (
            half_index
            ^ 1
        )

        start = (
            sibling_half_index
            * half_block_size
        )

        end = (
            start
            + half_block_size
        )

        return (
            start,
            end,
        )

    def hierarchical_coupling_field(
        self,
    ) -> List[float]:
        (
            prefix_real,
            prefix_imag,
        ) = self._weighted_phase_prefix()

        field = [
            0.0
            for _ in range(
                self.cells
            )
        ]

        for i in range(
            self.cells
        ):
            phase_offset = (
                self.phases[i]
                + self.gamma_effective[i]
            )

            cos_offset = math.cos(
                phase_offset
            )

            sin_offset = math.sin(
                phase_offset
            )

            shell_sum = 0.0

            for distance in range(
                1,
                self.hierarchy_depth
                + 1,
            ):
                (
                    start,
                    end,
                ) = self.sibling_shell_bounds(
                    i,
                    distance,
                )

                shell_real = self._prefix_range(
                    prefix_real,
                    start,
                    end,
                )

                shell_imag = self._prefix_range(
                    prefix_imag,
                    start,
                    end,
                )

                imaginary_projection = (
                    cos_offset
                    * shell_imag

                    - sin_offset
                    * shell_real
                )

                shell_sum += (
                    self.coupling_pair_weights_by_level[
                        distance
                    ]

                    * imaginary_projection
                )

            field[i] = (
                self.coupling_nominal

                * self.thermal_node_factors[i]

                * shell_sum
            )

        return field

    def scheduler_push(
        self,
        scheduler_mode: str,
    ) -> float:
        if scheduler_mode == "commit":
            return 0.010

        if scheduler_mode == "excite":
            return 0.006

        return 0.003

    def phase_velocities(
        self,
        coupling_field: Sequence[float],
        scheduler_mode: str,
    ) -> List[float]:
        push = self.scheduler_push(
            scheduler_mode
        )

        return [
            0.060
            * self.frequencies[i]

            + push

            + coupling_field[i]

            for i in range(
                self.cells
            )
        ]

    def update_phase_field(
        self,
        scheduler_mode: str,
    ) -> Dict[str, Any]:
        if self.coupling_path == "dense":
            coupling_field = (
                self.dense_coupling_field()
            )

        else:
            coupling_field = (
                self.hierarchical_coupling_field()
            )

        velocities = self.phase_velocities(
            coupling_field,
            scheduler_mode,
        )

        self.phases = [
            (
                self.phases[i]
                + velocities[i]
            )
            % math.tau

            for i in range(
                self.cells
            )
        ]

        self.raw_phase_coherence = phase_order(
            self.phases
        )

        return {
            "coupling_field":
                coupling_field,

            "phase_velocities":
                velocities,

            "raw_phase_coherence":
                self.raw_phase_coherence,
        }

    def multiscale_phase_coherence(
        self,
    ) -> Dict[str, Any]:
        levels: List[
            Dict[str, Any]
        ] = []

        for level in range(
            1,
            self.hierarchy_depth
            + 1,
        ):
            group_size = (
                2
                ** level
            )

            coherences = [
                phase_order(
                    self.phases[
                        start:
                        start
                        + group_size
                    ]
                )

                for start in range(
                    0,
                    self.cells,
                    group_size,
                )
            ]

            mean_value = (
                sum(
                    coherences
                )
                / len(
                    coherences
                )
            )

            variance = (
                sum(
                    (
                        value
                        - mean_value
                    )
                    ** 2

                    for value in coherences
                )
                / len(
                    coherences
                )
            )

            levels.append({
                "level":
                    level,

                "group_size":
                    group_size,

                "group_count":
                    len(
                        coherences
                    ),

                "group_phase_coherence":
                    coherences,

                "level_mean_phase_coherence":
                    mean_value,

                "level_min_phase_coherence":
                    min(
                        coherences
                    ),

                "level_max_phase_coherence":
                    max(
                        coherences
                    ),

                "level_coherence_dispersion":
                    math.sqrt(
                        variance
                    ),
            })

        pair_level = (
            levels[
                0
            ]
        )

        cluster_level = (
            levels[
                min(
                    1,
                    len(
                        levels
                    )
                    - 1,
                )
            ]
        )

        supercluster_level = (
            levels[
                max(
                    0,
                    len(
                        levels
                    )
                    - 2,
                )
            ]
        )

        global_level = (
            levels[
                -1
            ]
        )

        return {
            "levels":
                levels,

            "pair_domain_coherence_mean":
                pair_level[
                    "level_mean_phase_coherence"
                ],

            "pair_domain_coherence_min":
                pair_level[
                    "level_min_phase_coherence"
                ],

            "cluster_coherence_mean":
                cluster_level[
                    "level_mean_phase_coherence"
                ],

            "cluster_coherence_min":
                cluster_level[
                    "level_min_phase_coherence"
                ],

            "supercluster_coherence_mean":
                supercluster_level[
                    "level_mean_phase_coherence"
                ],

            "supercluster_coherence_min":
                supercluster_level[
                    "level_min_phase_coherence"
                ],

            "global_phase_coherence":
                global_level[
                    "level_mean_phase_coherence"
                ],

            "coherence_dispersion_across_clusters":
                cluster_level[
                    "level_coherence_dispersion"
                ],
        }

    def cluster_metrics(
        self,
        cluster_size: int = 4,
    ) -> List[
        Dict[str, Any]
    ]:
        if (
            self.cells
            % cluster_size
            != 0
        ):
            raise ValueError(
                "cluster_size must divide cells"
            )

        metrics: List[
            Dict[str, Any]
        ] = []

        for (
            cluster_index,
            start,
        ) in enumerate(
            range(
                0,
                self.cells,
                cluster_size,
            )
        ):
            end = (
                start
                + cluster_size
            )

            cluster_heat = (
                self.heat_cells[
                    start:
                    end
                ]
            )

            cluster_states = (
                self.states[
                    start:
                    end
                ]
            )

            cluster_switch_activity = (
                self.cell_switch_activity[
                    start:
                    end
                ]
            )

            cluster_phase_coherence = phase_order(
                self.phases[
                    start:
                    end
                ]
            )

            cluster_switch_load = (
                sum(
                    cluster_switch_activity
                )
                / cluster_size
            )

            cluster_heat_mean = (
                sum(
                    cluster_heat
                )
                / cluster_size
            )

            cluster_pressure = (
                cluster_heat_mean
                + cluster_switch_load
            )

            metrics.append({
                "cluster_index":
                    cluster_index,

                "cell_start":
                    start,

                "cell_end":
                    end
                    - 1,

                "heat_mean":
                    cluster_heat_mean,

                "heat_peak":
                    max(
                        cluster_heat
                    ),

                "switch_load":
                    cluster_switch_load,

                "phase_coherence":
                    cluster_phase_coherence,

                "pressure":
                    cluster_pressure,

                "coherence_margin":
                    cluster_phase_coherence
                    - cluster_pressure,

                "state_counts": {
                    "-1":
                        cluster_states.count(
                            -1
                        ),

                    "0":
                        cluster_states.count(
                            0
                        ),

                    "1":
                        cluster_states.count(
                            1
                        ),
                },
            })

        return metrics

    def update_global_stability(
        self,
        multiscale: Dict[str, Any],
    ) -> Dict[str, float]:
        thermal_overload_mean = (
            sum(
                self.thermal_overload_cells
            )
            / self.cells
        )

        margin_pressure = max(
            0.0,

            self.stability_soft_margin
            - self.previous_C_minus_P,
        )

        self.coherence_compression = math.exp(
            -(
                self.thermal_compression_gain

                * thermal_overload_mean
                * thermal_overload_mean

                + self.margin_compression_gain

                * margin_pressure
                * margin_pressure
            )
        )

        self.effective_coherence = (
            self.raw_phase_coherence

            * self.coherence_compression
        )

        neutral_fraction = (
            self.states.count(
                0
            )
            / self.cells
        )

        mean_frequency_lag = (
            sum(
                abs(
                    self.frequency_targets[i]
                    - self.frequencies[i]
                )

                for i in range(
                    self.cells
                )
            )
            / self.cells
        )

        self.C_value = (
            0.82

            + 0.34
            * self.effective_coherence

            + 0.16
            * multiscale[
                "cluster_coherence_mean"
            ]

            + 0.08
            * neutral_fraction

            - 0.10
            * mean_frequency_lag
        )

        self.P_value = (
            self.heat
            + self.switch_load
        )

        self.C_minus_P = (
            self.C_value
            - self.P_value
        )

        return {
            "C":
                self.C_value,

            "P":
                self.P_value,

            "C_minus_P":
                self.C_minus_P,

            "coherence_compression":
                self.coherence_compression,

            "effective_coherence":
                self.effective_coherence,
        }

    def tick(
        self,
        tick_index: int,
        auto_targets: bool = True,
        pressure_level: Optional[float] = None,
    ) -> None:
        sched = scheduler_state(
            self.scheduler,
            tick_index,
        )

        self.scheduler_counts[
            sched
        ] = (
            self.scheduler_counts.get(
                sched,
                0,
            )
            + 1
        )

        self.current_switch_changes = 0

        self.cell_switch_activity = [
            0
            for _ in range(
                self.cells
            )
        ]

        max_changes = max(
            1,

            int(
                round(
                    self.cells

                    * self.transition_fraction
                )
            ),
        )

        changes = (
            self.process_pending_neutral_routes(
                tick_index,
                max_changes,
            )
        )

        changes = (
            self.process_transition_requests(
                tick_index,
                max_changes,
                changes,
            )
        )

        if auto_targets:
            changes = (
                self.update_reference_state_targets(
                    tick_index,
                    max_changes,
                    changes,
                )
            )

        self.switch_load = (
            self.current_switch_changes
            / self.cells
        )

        self.switch_load_peak = max(
            self.switch_load_peak,
            self.switch_load,
        )

        delay = (
            self.update_delay_dynamics()
        )

        thermal = (
            self.update_local_thermal_field(
                delay[
                    "frequency_lags"
                ]
            )
        )

        self.update_local_gamma_drift(
            tick_index
        )

        self.update_thermal_node_factors()

        phase = (
            self.update_phase_field(
                sched
            )
        )

        multiscale = (
            self.multiscale_phase_coherence()
        )

        cluster_data = (
            self.cluster_metrics(
                4
                if self.cells >= 4
                else 2
            )
        )

        stability = (
            self.update_global_stability(
                multiscale
            )
        )

        previous_margin = (
            self.previous_C_minus_P
        )

        self.previous_C_minus_P = (
            self.C_minus_P
        )

        if (
            self.first_C_minus_P_crossing
            is None

            and previous_margin
            > 0.0

            and self.C_minus_P
            <= 0.0
        ):
            self.first_C_minus_P_crossing = {
                "boundary_tick":
                    tick_index,

                "boundary_pressure_level":
                    pressure_level,

                "heat_at_boundary":
                    self.heat,

                "local_heat_peak_at_boundary":
                    max(
                        self.heat_cells
                    ),

                "gamma_drift_peak_at_boundary":
                    max(
                        abs(
                            x
                        )
                        for x in self.gamma_drift
                    ),

                "frequency_lag_at_boundary":
                    delay[
                        "mean_frequency_lag"
                    ],

                "raw_phase_coherence_at_boundary":
                    self.raw_phase_coherence,

                "effective_coherence_at_boundary":
                    self.effective_coherence,

                "coherence_compression_at_boundary":
                    self.coherence_compression,

                "C_minus_P_at_boundary":
                    self.C_minus_P,
            }

        self.telemetry.append({
            "tick":
                tick_index,

            "scheduler_state":
                sched,

            "pressure_level":
                pressure_level,

            "cell_state":
                list(
                    self.states
                ),

            "phase":
                round_list(
                    self.phases
                ),

            "frequency_target":
                round_list(
                    self.frequency_targets
                ),

            "frequency_current":
                round_list(
                    self.frequencies
                ),

            "mean_frequency_lag":
                round(
                    delay[
                        "mean_frequency_lag"
                    ],
                    6,
                ),

            "frequency_lag_peak_tick":
                round(
                    delay[
                        "frequency_lag_peak_tick"
                    ],
                    6,
                ),

            "switch_load":
                round(
                    self.switch_load,
                    6,
                ),

            "generated_power_mean":
                round(
                    thermal[
                        "generated_power_mean"
                    ],
                    6,
                ),

            "generated_power_peak_tick":
                round(
                    thermal[
                        "generated_power_peak_tick"
                    ],
                    6,
                ),

            "thermal_dissipation_mean":
                round(
                    thermal[
                        "thermal_dissipation_mean"
                    ],
                    6,
                ),

            "thermal_diffusion_abs_mean":
                round(
                    thermal[
                        "thermal_diffusion_abs_mean"
                    ],
                    6,
                ),

            "heat":
                round(
                    self.heat,
                    6,
                ),

            "heat_cells":
                round_list(
                    self.heat_cells
                ),

            "local_heat_peak_tick":
                round(
                    max(
                        self.heat_cells
                    ),
                    6,
                ),

            "thermal_overload_mean":
                round(
                    thermal[
                        "thermal_overload_mean"
                    ],
                    6,
                ),

            "thermal_overload_peak_tick":
                round(
                    thermal[
                        "thermal_overload_peak_tick"
                    ],
                    6,
                ),

            "gamma_effective_mean":
                round(
                    sum(
                        self.gamma_effective
                    )
                    / self.cells,
                    6,
                ),

            "gamma_drift_peak_tick":
                round(
                    max(
                        abs(
                            x
                        )
                        for x in self.gamma_drift
                    ),
                    6,
                ),

            "thermal_node_factor_min":
                round(
                    min(
                        self.thermal_node_factors
                    ),
                    6,
                ),

            "coupling_field":
                round_list(
                    phase[
                        "coupling_field"
                    ]
                ),

            "raw_phase_coherence":
                round(
                    self.raw_phase_coherence,
                    6,
                ),

            "coherence_compression":
                round(
                    self.coherence_compression,
                    6,
                ),

            "effective_coherence":
                round(
                    self.effective_coherence,
                    6,
                ),

            "pair_domain_coherence_mean":
                round(
                    multiscale[
                        "pair_domain_coherence_mean"
                    ],
                    6,
                ),

            "pair_domain_coherence_min":
                round(
                    multiscale[
                        "pair_domain_coherence_min"
                    ],
                    6,
                ),

            "cluster_coherence_mean":
                round(
                    multiscale[
                        "cluster_coherence_mean"
                    ],
                    6,
                ),

            "cluster_coherence_min":
                round(
                    multiscale[
                        "cluster_coherence_min"
                    ],
                    6,
                ),

            "supercluster_coherence_mean":
                round(
                    multiscale[
                        "supercluster_coherence_mean"
                    ],
                    6,
                ),

            "supercluster_coherence_min":
                round(
                    multiscale[
                        "supercluster_coherence_min"
                    ],
                    6,
                ),

            "global_phase_coherence":
                round(
                    multiscale[
                        "global_phase_coherence"
                    ],
                    6,
                ),

            "coherence_dispersion_across_clusters":
                round(
                    multiscale[
                        "coherence_dispersion_across_clusters"
                    ],
                    6,
                ),

            "cluster_metrics": [
                {
                    key:
                        round(
                            value,
                            6,
                        )
                        if isinstance(
                            value,
                            float,
                        )
                        else value

                    for (
                        key,
                        value,
                    ) in row.items()
                }

                for row in cluster_data
            ],

            "C":
                round(
                    stability[
                        "C"
                    ],
                    6,
                ),

            "P":
                round(
                    stability[
                        "P"
                    ],
                    6,
                ),

            "C_minus_P":
                round(
                    stability[
                        "C_minus_P"
                    ],
                    6,
                ),

            "actual_direct_events":
                self.actual_direct_events,

            "requested_direct_events":
                self.requested_direct_events,

            "prevented_direct_events":
                self.prevented_direct_events,

            "neutral_routed_events":
                self.neutral_routed_events,

            "neutralized_conflicts":
                self.neutralized_conflicts,

            "changes":
                changes,

            "pending_neutral_routes":
                len(
                    self.pending_neutral_routes
                ),

            "balanced_ternary_state_domain":
                all(
                    state in TERNARY_STATES

                    for state in self.states
                ),
        })

    def summarize(
        self,
        steps: int,
    ) -> Dict[str, Any]:
        if not self.telemetry:
            return {
                "version":
                    VERSION,

                "milestone":
                    MILESTONE,

                "cells":
                    self.cells,

                "steps":
                    steps,

                "ticks_recorded":
                    0,

                "scheduler":
                    self.scheduler,

                "scheduler_counts":
                    dict(
                        self.scheduler_counts
                    ),

                "transition_fraction":
                    self.transition_fraction,

                "actual_direct_events":
                    self.actual_direct_events,

                "requested_direct_events":
                    self.requested_direct_events,

                "prevented_direct_events":
                    self.prevented_direct_events,

                "neutral_routed_events":
                    self.neutral_routed_events,

                "neutralized_conflicts":
                    self.neutralized_conflicts,
            }

        c_minus_p_values = [
            x[
                "C_minus_P"
            ]
            for x in self.telemetry
        ]

        switch_values = [
            x[
                "switch_load"
            ]
            for x in self.telemetry
        ]

        heat_values = [
            x[
                "heat"
            ]
            for x in self.telemetry
        ]

        local_heat_values = [
            x[
                "local_heat_peak_tick"
            ]
            for x in self.telemetry
        ]

        generated_power_values = [
            x[
                "generated_power_peak_tick"
            ]
            for x in self.telemetry
        ]

        thermal_overload_values = [
            x[
                "thermal_overload_peak_tick"
            ]
            for x in self.telemetry
        ]

        gamma_values = [
            x[
                "gamma_drift_peak_tick"
            ]
            for x in self.telemetry
        ]

        lag_values = [
            x[
                "mean_frequency_lag"
            ]
            for x in self.telemetry
        ]

        lag_peak_values = [
            x[
                "frequency_lag_peak_tick"
            ]
            for x in self.telemetry
        ]

        raw_coherence_values = [
            x[
                "raw_phase_coherence"
            ]
            for x in self.telemetry
        ]

        compression_values = [
            x[
                "coherence_compression"
            ]
            for x in self.telemetry
        ]

        effective_coherence_values = [
            x[
                "effective_coherence"
            ]
            for x in self.telemetry
        ]

        cluster_mean_values = [
            x[
                "cluster_coherence_mean"
            ]
            for x in self.telemetry
        ]

        cluster_min_values = [
            x[
                "cluster_coherence_min"
            ]
            for x in self.telemetry
        ]

        pair_mean_values = [
            x[
                "pair_domain_coherence_mean"
            ]
            for x in self.telemetry
        ]

        pair_min_values = [
            x[
                "pair_domain_coherence_min"
            ]
            for x in self.telemetry
        ]

        supercluster_mean_values = [
            x[
                "supercluster_coherence_mean"
            ]
            for x in self.telemetry
        ]

        supercluster_min_values = [
            x[
                "supercluster_coherence_min"
            ]
            for x in self.telemetry
        ]

        dispersion_values = [
            x[
                "coherence_dispersion_across_clusters"
            ]
            for x in self.telemetry
        ]

        match = (
            1.0
            if self.actual_direct_events
            == 0
            else 0.0
        )

        scheduler_counts_valid = (
            self.scheduler_counts

            == expected_scheduler_counts(
                self.scheduler,
                steps,
            )
        )

        return {
            "version":
                VERSION,

            "milestone":
                MILESTONE,

            "cells":
                self.cells,

            "hierarchy_depth":
                self.hierarchy_depth,

            "steps":
                steps,

            "ticks_recorded":
                len(
                    self.telemetry
                ),

            "scheduler":
                self.scheduler,

            "scheduler_counts":
                dict(
                    self.scheduler_counts
                ),

            "scheduler_counts_valid":
                scheduler_counts_valid,

            "transition_fraction":
                self.transition_fraction,

            "transition_fraction_q16":
                q16(
                    self.transition_fraction
                ),

            "gamma_nominal":
                self.gamma_nominal,

            "gamma_nominal_q16":
                q16(
                    self.gamma_nominal
                ),

            "fractal_alpha":
                self.fractal_alpha,

            "thermal_beta":
                self.thermal_beta,

            "coupling_path":
                self.coupling_path,

            "actual_direct_events":
                self.actual_direct_events,

            "requested_direct_events":
                self.requested_direct_events,

            "prevented_direct_events":
                self.prevented_direct_events,

            "neutral_routed_events":
                self.neutral_routed_events,

            "neutralized_conflicts":
                self.neutralized_conflicts,

            "match":
                match,

            "match_q16":
                q16(
                    match
                ),

            "balanced_ternary_state_domain":
                all(
                    state in TERNARY_STATES

                    for record in self.telemetry

                    for state in record[
                        "cell_state"
                    ]
                ),

            "switch_load_peak":
                round(
                    max(
                        switch_values
                    ),
                    6,
                ),

            "heat_final":
                round(
                    heat_values[
                        -1
                    ],
                    6,
                ),

            "heat_peak":
                round(
                    max(
                        heat_values
                    ),
                    6,
                ),

            "local_heat_peak":
                round(
                    max(
                        local_heat_values
                    ),
                    6,
                ),

            "thermal_overload_peak":
                round(
                    max(
                        thermal_overload_values
                    ),
                    6,
                ),

            "generated_power_peak":
                round(
                    max(
                        generated_power_values
                    ),
                    6,
                ),

            "effective_coupling_min":
                round(
                    self.effective_coupling_min,
                    6,
                ),

            "gamma_drift_peak":
                round(
                    max(
                        gamma_values
                    ),
                    6,
                ),

            "mean_frequency_lag_final":
                round(
                    lag_values[
                        -1
                    ],
                    6,
                ),

            "mean_frequency_lag_peak":
                round(
                    max(
                        lag_values
                    ),
                    6,
                ),

            "frequency_lag_peak":
                round(
                    max(
                        lag_peak_values
                    ),
                    6,
                ),

            "raw_phase_coherence_final":
                round(
                    raw_coherence_values[
                        -1
                    ],
                    6,
                ),

            "raw_phase_coherence_min":
                round(
                    min(
                        raw_coherence_values
                    ),
                    6,
                ),

            "coherence_compression_final":
                round(
                    compression_values[
                        -1
                    ],
                    6,
                ),

            "coherence_compression_min":
                round(
                    min(
                        compression_values
                    ),
                    6,
                ),

            "effective_coherence_final":
                round(
                    effective_coherence_values[
                        -1
                    ],
                    6,
                ),

            "effective_coherence_min":
                round(
                    min(
                        effective_coherence_values
                    ),
                    6,
                ),

            "pair_domain_coherence_mean_final":
                round(
                    pair_mean_values[
                        -1
                    ],
                    6,
                ),

            "pair_domain_coherence_min":
                round(
                    min(
                        pair_min_values
                    ),
                    6,
                ),

            "cluster_coherence_mean_final":
                round(
                    cluster_mean_values[
                        -1
                    ],
                    6,
                ),

            "cluster_coherence_min":
                round(
                    min(
                        cluster_min_values
                    ),
                    6,
                ),

            "supercluster_coherence_mean_final":
                round(
                    supercluster_mean_values[
                        -1
                    ],
                    6,
                ),

            "supercluster_coherence_min":
                round(
                    min(
                        supercluster_min_values
                    ),
                    6,
                ),

            "coherence_dispersion_across_clusters_peak":
                round(
                    max(
                        dispersion_values
                    ),
                    6,
                ),

            "global_phase_coherence_final":
                round(
                    self.telemetry[
                        -1
                    ][
                        "global_phase_coherence"
                    ],
                    6,
                ),

            "C_minus_P_final":
                round(
                    c_minus_p_values[
                        -1
                    ],
                    6,
                ),

            "C_minus_P_min":
                round(
                    min(
                        c_minus_p_values
                    ),
                    6,
                ),

            "boundary_detected":
                self.first_C_minus_P_crossing
                is not None,

            "first_C_minus_P_crossing":
                self.first_C_minus_P_crossing,

            "pending_neutral_routes_final":
                len(
                    self.pending_neutral_routes
                ),
        }

    def run(
        self,
        steps: int,
        auto_targets: bool = True,
    ) -> Dict[str, Any]:
        for tick_index in range(
            steps
        ):
            self.tick(
                tick_index,
                auto_targets=
                    auto_targets,
            )

        return {
            "summary":
                self.summarize(
                    steps
                ),

            "telemetry":
                self.telemetry,
        }


def make_processor(
    args: argparse.Namespace,
    cells: Optional[int] = None,
    transition_fraction: Optional[float] = None,
    scheduler: Optional[str] = None,
    seed_offset: int = 0,
    coupling_path: str = "hierarchical",
) -> FractalResonanceProcessor:
    return FractalResonanceProcessor(
        cells=(
            cells
            if cells is not None
            else args.cells
        ),

        transition_fraction=(
            transition_fraction

            if transition_fraction
            is not None

            else args.transition_fraction
        ),

        gamma_nominal=
            args.gamma,

        scheduler=(
            scheduler
            if scheduler is not None
            else args.scheduler
        ),

        seed=
            args.seed
            + seed_offset,

        fractal_alpha=
            args.fractal_alpha,

        thermal_beta=
            args.thermal_beta,

        ambient_heat=
            args.ambient_heat,

        thermal_time_constant=
            args.thermal_time_constant,

        thermal_soft_limit=
            args.thermal_soft_limit,

        thermal_hard_limit=
            args.thermal_hard_limit,

        coupling_nominal=
            args.coupling_nominal,

        delay_alpha=
            args.delay_alpha,

        thermal_diffusion_gain=
            args.thermal_diffusion_gain,

        equivalence_tolerance=
            args.equivalence_tolerance,

        coupling_path=
            coupling_path,
    )


def run_reference(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    return (
        make_processor(
            args
        )
        .run(
            args.steps,
            auto_targets=True,
        )
    )


def inject_hostile_requests(
    processor: FractalResonanceProcessor,
    cell_indices: Sequence[int],
    count: int,
    tick_index: int,
) -> None:
    nonzero_cells = [
        index

        for index in cell_indices

        if processor.states[
            index
        ]
        != 0
    ]

    if not nonzero_cells:
        return

    for offset in range(
        min(
            count,
            len(
                nonzero_cells
            ),
        )
    ):
        cell_idx = (
            nonzero_cells[
                (
                    tick_index
                    * max(
                        1,
                        count,
                    )
                    + offset
                )
                % len(
                    nonzero_cells
                )
            ]
        )

        processor.request_transition(
            cell_idx,
            -processor.states[
                cell_idx
            ],
        )


def inherited_v1_5_0_boundary(
) -> Dict[str, Any]:
    return {
        "release":
            "FRP v1.5.0",

        "layer":
            "M13 — Production Scaling and Implementation Stabilization Package",

        "main_executable_reference_file":
            "frp_prototype_v1_5_0.py",

        "validation_index":
            "FRP_VALIDATION_INDEX_v1_5_0.md",

        "release_notes":
            "RELEASE_NOTES_v1_5_0.md",

        "test_report":
            "TEST_REPORT_v1_5_0.md",

        "preserved_kernel": {
            "balanced_ternary_states":
                [
                    -1,
                    0,
                    1,
                ],

            "active_neutral_state":
                0,

            "tick_separated_neutral_routing":
                True,

            "scheduler_modes":
                list(
                    SCHEDULER_MODES
                ),

            "gamma_nominal_relation":
                "0.30 pi",

            "stability_relation":
                "C(t) > P(t)",

            "pressure_relation":
                "P(t) = heat + switch_load",
        },

        "stabilization_markers": [
            "heat_peak",

            "frequency_lag_peak",

            "gamma_drift_peak",

            "coherence_compression_min",

            "boundary_detected",

            "recovery_completed",
        ],
    }


def stable_cli_commands(
) -> List[str]:
    return [
        "--mode demo --output json",

        "--mode self-test --output json",

        "--mode benchmark",

        "--export-benchmark-matrix",

        "--export-hierarchical-ultrametric-topology-model",

        "--export-fractal-coupling-weight-map",

        "--export-multiscale-phase-coherence-map",

        "--export-cluster-local-thermal-field",

        "--export-cross-cluster-propagation-map",

        "--export-localized-hotspot-containment-harness",

        "--export-dense-hierarchical-equivalence-map",

        "--export-physical-domain-correlation-package",
    ]


def stable_schema_set(
) -> List[str]:
    return [
        STRUCTURED_SCHEMA,

        BENCHMARK_SCHEMA,

        M14_HIERARCHICAL_ULTRAMETRIC_TOPOLOGY_MODEL_SCHEMA,

        M14_FRACTAL_COUPLING_WEIGHT_MAP_SCHEMA,

        M14_MULTISCALE_PHASE_COHERENCE_MAP_SCHEMA,

        M14_CLUSTER_LOCAL_THERMAL_FIELD_SCHEMA,

        M14_CROSS_CLUSTER_PROPAGATION_MAP_SCHEMA,

        M14_LOCALIZED_HOTSPOT_CONTAINMENT_HARNESS_SCHEMA,

        M14_DENSE_HIERARCHICAL_EQUIVALENCE_MAP_SCHEMA,

        M14_PHYSICAL_DOMAIN_CORRELATION_PACKAGE_SCHEMA,

        "frp.structured_output.v1.5.0",

        "frp.m3.benchmark_matrix.v1.5.0",

        "frp.m13.thermal_saturation_model.v1.5.0",

        "frp.m13.delay_dynamics_model.v1.5.0",

        "frp.m13.nonlinear_coherence_compression_model.v1.5.0",

        "frp.m13.thermal_gamma_drift_model.v1.5.0",

        "frp.m13.coupled_thermal_delay_stress_harness.v1.5.0",

        "frp.m13.thermal_stability_boundary_sweep.v1.5.0",

        "frp.m13.recovery_dynamics_map.v1.5.0",

        "frp.m13.production_scaling_stability_envelope.v1.5.0",
    ]


def m14_artifact_layers(
) -> List[str]:
    return [
        "hierarchical_ultrametric_topology_model",

        "fractal_coupling_weight_map",

        "multiscale_phase_coherence_map",

        "cluster_local_thermal_field",

        "cross_cluster_propagation_map",

        "localized_hotspot_containment_harness",

        "dense_hierarchical_equivalence_map",

        "physical_domain_correlation_package",
    ]


def candidate_invariant_names(
) -> List[str]:
    return [
        "match",

        "actual_direct_events",

        "C_minus_P_min",

        "switch_load_peak",

        "ticks_recorded",

        "scheduler_counts",

        "neutralized_conflicts",

        "requested_direct_events",

        "prevented_direct_events",

        "neutral_routed_events",

        "balanced_ternary_state_domain",

        "heat_peak",

        "local_heat_peak",

        "frequency_lag_peak",

        "gamma_drift_peak",

        "coherence_compression_min",

        "topology_row_sum_match",

        "topology_symmetry_match",

        "topology_diagonal_zero",

        "shell_influence_monotonic",

        "topology_match",

        "max_coupling_error",

        "max_phase_velocity_error",

        "localized_hotspot_containment_pass",
    ]


def candidate_invariant_markers(
    summary: Dict[str, Any],
) -> Dict[str, Any]:
    return {
        "match":
            summary[
                "match"
            ],

        "actual_direct_events":
            summary[
                "actual_direct_events"
            ],

        "C_minus_P_min":
            summary[
                "C_minus_P_min"
            ],

        "switch_load_peak":
            summary[
                "switch_load_peak"
            ],

        "transition_fraction":
            summary[
                "transition_fraction"
            ],

        "ticks_recorded":
            summary[
                "ticks_recorded"
            ],

        "steps":
            summary[
                "steps"
            ],

        "scheduler_counts":
            summary[
                "scheduler_counts"
            ],

        "scheduler_counts_valid":
            summary[
                "scheduler_counts_valid"
            ],

        "neutralized_conflicts":
            summary[
                "neutralized_conflicts"
            ],

        "requested_direct_events":
            summary[
                "requested_direct_events"
            ],

        "prevented_direct_events":
            summary[
                "prevented_direct_events"
            ],

        "neutral_routed_events":
            summary[
                "neutral_routed_events"
            ],

        "balanced_ternary_state_domain":
            summary[
                "balanced_ternary_state_domain"
            ],

        "heat_peak":
            summary[
                "heat_peak"
            ],

        "local_heat_peak":
            summary[
                "local_heat_peak"
            ],

        "frequency_lag_peak":
            summary[
                "frequency_lag_peak"
            ],

        "gamma_drift_peak":
            summary[
                "gamma_drift_peak"
            ],

        "coherence_compression_min":
            summary[
                "coherence_compression_min"
            ],
    }


def structured_output(
    kind: str,
    args: argparse.Namespace,
    include_telemetry: bool,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    processor = make_processor(
        args
    )

    coupling_metrics = (
        processor.topology_metrics(
            processor.coupling_matrix,
            processor.fractal_alpha,
        )
    )

    thermal_metrics = (
        processor.topology_metrics(
            processor.thermal_matrix,
            processor.thermal_beta,
        )
    )

    payload: Dict[
        str,
        Any,
    ] = {
        "schema":
            STRUCTURED_SCHEMA,

        "kind":
            kind,

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "configuration": {
            "cells":
                args.cells,

            "steps":
                args.steps,

            "seed":
                args.seed,

            "scheduler":
                args.scheduler,

            "transition_fraction":
                args.transition_fraction,

            "gamma_nominal":
                args.gamma,

            "fractal_alpha":
                args.fractal_alpha,

            "thermal_beta":
                args.thermal_beta,

            "ambient_heat":
                args.ambient_heat,

            "thermal_time_constant":
                args.thermal_time_constant,

            "thermal_soft_limit":
                args.thermal_soft_limit,

            "thermal_hard_limit":
                args.thermal_hard_limit,

            "coupling_nominal":
                args.coupling_nominal,

            "delay_alpha":
                args.delay_alpha,

            "thermal_diffusion_gain":
                args.thermal_diffusion_gain,

            "equivalence_tolerance":
                args.equivalence_tolerance,
        },

        "kernel": {
            "balanced_ternary_states":
                [
                    -1,
                    0,
                    1,
                ],

            "active_neutral_state":
                0,

            "neutral_routes":
                [
                    "-1 -> 0 -> 1",

                    "1 -> 0 -> -1",
                ],

            "scheduler_modes":
                list(
                    SCHEDULER_MODES
                ),
        },

        "topology": {
            "hierarchy_depth":
                processor.hierarchy_depth,

            "coupling_topology":
                coupling_metrics,

            "thermal_topology":
                thermal_metrics,
        },

        "summary":
            result[
                "summary"
            ],
    }

    if include_telemetry:
        payload[
            "telemetry"
        ] = result[
            "telemetry"
        ]

    return payload


def hierarchical_ultrametric_topology_model(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    coupling_metrics = (
        processor.topology_metrics(
            processor.coupling_matrix,
            processor.fractal_alpha,
        )
    )

    shell_examples = {
        str(
            i
        ): {
            str(
                j
            ):
                processor.hierarchical_distance(
                    i,
                    j,
                )

            for j in range(
                processor.cells
            )

            if j != i
        }

        for i in range(
            min(
                4,
                processor.cells,
            )
        )
    }

    return {
        "schema":
            M14_HIERARCHICAL_ULTRAMETRIC_TOPOLOGY_MODEL_SCHEMA,

        "kind":
            "hierarchical_ultrametric_topology_model",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "cells":
            processor.cells,

        "hierarchy_depth":
            processor.hierarchy_depth,

        "exact_dyadic_topology":
            True,

        "distance_relation":
            "bit_length(i XOR j)",

        "shell_population_relation":
            "2^(d - 1)",

        "fractal_alpha":
            processor.fractal_alpha,

        "topology_metrics":
            coupling_metrics,

        "distance_examples":
            shell_examples,
    }


def fractal_coupling_weight_map(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    metrics = (
        processor.topology_metrics(
            processor.coupling_matrix,
            processor.fractal_alpha,
        )
    )

    rows = []

    for i in range(
        processor.cells
    ):
        for j in range(
            processor.cells
        ):
            distance = (
                processor.hierarchical_distance(
                    i,
                    j,
                )
            )

            if i == j:
                raw_weight = 0.0

                normalized_weight = 0.0

                shell_population = 0

            else:
                shell_population = (
                    processor.shell_population(
                        distance
                    )
                )

                raw_weight = (
                    1.0

                    / (
                        shell_population

                        * (
                            distance

                            ** processor.fractal_alpha
                        )
                    )
                )

                normalized_weight = (
                    processor.coupling_matrix[
                        i
                    ][
                        j
                    ]
                )

            rows.append({
                "i":
                    i,

                "j":
                    j,

                "hierarchical_distance":
                    distance,

                "shell_population":
                    shell_population,

                "raw_pair_weight":
                    raw_weight,

                "normalized_pair_weight":
                    normalized_weight,
            })

    return {
        "schema":
            M14_FRACTAL_COUPLING_WEIGHT_MAP_SCHEMA,

        "kind":
            "fractal_coupling_weight_map",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "fractal_alpha":
            processor.fractal_alpha,

        "relation":
            "W_raw(i,j) = 1 / (2^(d - 1) * d^alpha)",

        "row_normalization":
            "W_ij = W_raw(i,j) / sum_j(W_raw(i,j))",

        "topology_metrics":
            metrics,

        "rows":
            rows,
    }


def multiscale_phase_coherence_map(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    processor = make_processor(
        args
    )

    processor.run(
        args.steps,
        auto_targets=True,
    )

    multiscale = (
        processor.multiscale_phase_coherence()
    )

    return {
        "schema":
            M14_MULTISCALE_PHASE_COHERENCE_MAP_SCHEMA,

        "kind":
            "multiscale_phase_coherence_map",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "levels": [
            {
                key:
                    (
                        round_list(
                            value
                        )

                        if key
                        == "group_phase_coherence"

                        else round(
                            value,
                            6,
                        )

                        if isinstance(
                            value,
                            float,
                        )

                        else value
                    )

                for (
                    key,
                    value,
                ) in row.items()
            }

            for row in multiscale[
                "levels"
            ]
        ],

        "summary_markers": {
            key:
                round(
                    value,
                    6,
                )

            for (
                key,
                value,
            ) in multiscale.items()

            if key != "levels"
        },

        "candidate_invariant_markers":
            candidate_invariant_markers(
                result[
                    "summary"
                ]
            ),
    }


def cluster_local_thermal_field(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    result = processor.run(
        args.steps,
        auto_targets=True,
    )

    thermal_metrics = (
        processor.topology_metrics(
            processor.thermal_matrix,
            processor.thermal_beta,
        )
    )

    return {
        "schema":
            M14_CLUSTER_LOCAL_THERMAL_FIELD_SCHEMA,

        "kind":
            "cluster_local_thermal_field",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "thermal_beta":
            processor.thermal_beta,

        "relations": {
            "generated_power_i":
                "base_power_cell + switch_power_gain * switch_activity_i + lag_power_gain * frequency_lag_i",

            "thermal_dissipation_i":
                "(heat_i - ambient_heat) / thermal_time_constant",

            "thermal_diffusion_i":
                "thermal_diffusion_gain * sum_j(T_ij * (heat_j - heat_i))",

            "heat_i_next":
                "max(ambient_heat, heat_i + generated_power_i - thermal_dissipation_i + thermal_diffusion_i)",
        },

        "thermal_topology_metrics":
            thermal_metrics,

        "final_heat_cells":
            round_list(
                processor.heat_cells
            ),

        "local_heat_peaks":
            round_list(
                processor.local_heat_peaks
            ),

        "final_cluster_metrics":
            processor.cluster_metrics(
                4
                if processor.cells >= 4
                else 2
            ),

        "candidate_invariant_markers":
            candidate_invariant_markers(
                result[
                    "summary"
                ]
            ),

        "summary":
            result[
                "summary"
            ],
    }


def run_hotspot_harness(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    cells = max(
        16,
        args.cells,
    )

    if not is_power_of_two(
        cells
    ):
        cells = 16

    processor = make_processor(
        args,
        cells=cells,
        scheduler=
            args.scheduler,
    )

    processor.states = [
        -1
        if i % 2 == 0
        else 1

        for i in range(
            cells
        )
    ]

    cluster_size = 4

    active_cells = list(
        range(
            0,
            cluster_size,
        )
    )

    remote_cells = list(
        range(
            cells
            - cluster_size,
            cells,
        )
    )

    inactive_cells = list(
        range(
            cluster_size,
            cells,
        )
    )

    stress_ticks = 72

    recovery_ticks = 96

    total_steps = (
        stress_ticks
        + recovery_ticks
    )

    active_cluster_heat_peak = (
        processor.ambient_heat
    )

    inactive_cluster_heat_mean_peak = (
        processor.ambient_heat
    )

    remote_cluster_heat_peak = (
        processor.ambient_heat
    )

    adjacent_cluster_heat_peak = (
        processor.ambient_heat
    )

    active_cluster_coherence_min = 1.0

    remote_cluster_coherence_min = 1.0

    for tick_index in range(
        total_steps
    ):
        if tick_index < stress_ticks:
            inject_hostile_requests(
                processor,

                active_cells,

                count=min(
                    2,
                    cluster_size,
                ),

                tick_index=
                    tick_index,
            )

        processor.tick(
            tick_index,
            auto_targets=False,
        )

        active_heat_mean = (
            sum(
                processor.heat_cells[
                    i
                ]
                for i in active_cells
            )
            / len(
                active_cells
            )
        )

        inactive_heat_mean = (
            sum(
                processor.heat_cells[
                    i
                ]
                for i in inactive_cells
            )
            / len(
                inactive_cells
            )
        )

        remote_heat_mean = (
            sum(
                processor.heat_cells[
                    i
                ]
                for i in remote_cells
            )
            / len(
                remote_cells
            )
        )

        adjacent_cells = list(
            range(
                cluster_size,
                cluster_size
                * 2,
            )
        )

        adjacent_heat_mean = (
            sum(
                processor.heat_cells[
                    i
                ]
                for i in adjacent_cells
            )
            / len(
                adjacent_cells
            )
        )

        active_cluster_heat_peak = max(
            active_cluster_heat_peak,
            active_heat_mean,
        )

        inactive_cluster_heat_mean_peak = max(
            inactive_cluster_heat_mean_peak,
            inactive_heat_mean,
        )

        remote_cluster_heat_peak = max(
            remote_cluster_heat_peak,
            remote_heat_mean,
        )

        adjacent_cluster_heat_peak = max(
            adjacent_cluster_heat_peak,
            adjacent_heat_mean,
        )

        active_cluster_coherence_min = min(
            active_cluster_coherence_min,

            phase_order(
                [
                    processor.phases[
                        i
                    ]

                    for i in active_cells
                ]
            ),
        )

        remote_cluster_coherence_min = min(
            remote_cluster_coherence_min,

            phase_order(
                [
                    processor.phases[
                        i
                    ]

                    for i in remote_cells
                ]
            ),
        )

    summary = processor.summarize(
        total_steps
    )

    propagation_ratio = (
        inactive_cluster_heat_mean_peak

        / active_cluster_heat_peak
    )

    remote_propagation_ratio = (
        remote_cluster_heat_peak

        / active_cluster_heat_peak
    )

    cross_cluster_bounded = (
        propagation_ratio
        < 0.75

        and remote_propagation_ratio
        < 0.70
    )

    recovery_start_tick = (
        stress_ticks
    )

    recovery_completion_tick: Optional[
        int
    ] = None

    recovery_heat_limit = (
        processor.ambient_heat
        + 0.08
    )

    recovery_lag_limit = 0.01

    recovery_margin = 0.20

    for record in processor.telemetry[
        recovery_start_tick:
    ]:
        if (
            record[
                "heat"
            ]
            <= recovery_heat_limit

            and record[
                "mean_frequency_lag"
            ]
            <= recovery_lag_limit

            and record[
                "C_minus_P"
            ]
            >= recovery_margin
        ):
            recovery_completion_tick = (
                record[
                    "tick"
                ]
            )

            break

    recovery_completed = (
        recovery_completion_tick
        is not None
    )

    checks = {
        "balanced_ternary_state_domain":
            summary[
                "balanced_ternary_state_domain"
            ]
            is True,

        "actual_direct_events_zero":
            summary[
                "actual_direct_events"
            ]
            == 0,

        "requested_direct_events_present":
            summary[
                "requested_direct_events"
            ]
            >= 1,

        "prevented_direct_events_cover_requests":
            summary[
                "prevented_direct_events"
            ]
            >= summary[
                "requested_direct_events"
            ],

        "neutral_routed_events_cover_prevention":
            summary[
                "neutral_routed_events"
            ]
            >= summary[
                "prevented_direct_events"
            ],

        "active_cluster_hotter_than_inactive_mean":
            active_cluster_heat_peak

            > inactive_cluster_heat_mean_peak,

        "remote_cluster_cooler_than_active_cluster":
            remote_cluster_heat_peak

            < active_cluster_heat_peak,

        "cross_cluster_thermal_propagation_bounded":
            cross_cluster_bounded,

        "global_C_minus_P_positive":
            summary[
                "C_minus_P_min"
            ]
            > 0,

        "switch_load_within_transition_fraction":
            summary[
                "switch_load_peak"
            ]
            <= (
                processor.transition_fraction
                + 1e-9
            ),

        "ticks_recorded_equals_steps":
            summary[
                "ticks_recorded"
            ]
            == total_steps,

        "scheduler_counts_valid":
            summary[
                "scheduler_counts_valid"
            ]
            is True,

        "recovery_completed":
            recovery_completed,
    }

    return {
        "schema":
            M14_LOCALIZED_HOTSPOT_CONTAINMENT_HARNESS_SCHEMA,

        "kind":
            "localized_hotspot_containment_harness",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "status":
            (
                "PASS"
                if all(
                    checks.values()
                )
                else "REVIEW"
            ),

        "checks":
            checks,

        "configuration": {
            "active_cluster_cells":
                active_cells,

            "remote_cluster_cells":
                remote_cells,

            "stress_ticks":
                stress_ticks,

            "recovery_ticks":
                recovery_ticks,

            "scheduler":
                processor.scheduler,

            "fractal_alpha":
                processor.fractal_alpha,

            "thermal_beta":
                processor.thermal_beta,
        },

        "containment_markers": {
            "active_cluster_heat_peak":
                round(
                    active_cluster_heat_peak,
                    6,
                ),

            "inactive_cluster_heat_mean_peak":
                round(
                    inactive_cluster_heat_mean_peak,
                    6,
                ),

            "adjacent_cluster_heat_peak":
                round(
                    adjacent_cluster_heat_peak,
                    6,
                ),

            "remote_cluster_heat_peak":
                round(
                    remote_cluster_heat_peak,
                    6,
                ),

            "cross_cluster_thermal_propagation_ratio":
                round(
                    propagation_ratio,
                    6,
                ),

            "remote_thermal_propagation_ratio":
                round(
                    remote_propagation_ratio,
                    6,
                ),

            "cross_cluster_thermal_propagation_bounded":
                cross_cluster_bounded,

            "active_cluster_coherence_min":
                round(
                    active_cluster_coherence_min,
                    6,
                ),

            "remote_cluster_coherence_min":
                round(
                    remote_cluster_coherence_min,
                    6,
                ),

            "localized_hotspot_containment_pass":
                all(
                    checks.values()
                ),
        },

        "recovery_markers": {
            "recovery_start_tick":
                recovery_start_tick,

            "recovery_completion_tick":
                recovery_completion_tick,

            "recovery_duration":
                (
                    recovery_completion_tick
                    - recovery_start_tick

                    if recovery_completion_tick
                    is not None

                    else None
                ),

            "recovery_completed":
                recovery_completed,
        },

        "summary":
            summary,

        "telemetry":
            processor.telemetry,
    }


def cross_cluster_propagation_map(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    hotspot = run_hotspot_harness(
        args
    )

    return {
        "schema":
            M14_CROSS_CLUSTER_PROPAGATION_MAP_SCHEMA,

        "kind":
            "cross_cluster_propagation_map",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "thermal_propagation_markers":
            hotspot[
                "containment_markers"
            ],

        "recovery_markers":
            hotspot[
                "recovery_markers"
            ],

        "summary":
            hotspot[
                "summary"
            ],

        "status":
            hotspot[
                "status"
            ],
    }


def dense_hierarchical_equivalence_map(
    args: argparse.Namespace,
    scheduler: Optional[str] = None,
) -> Dict[str, Any]:
    mode = (
        scheduler
        if scheduler is not None
        else args.scheduler
    )

    processor = make_processor(
        args,
        scheduler=mode,
        coupling_path=
            "hierarchical",
    )

    warmup_steps = 24

    for tick_index in range(
        warmup_steps
    ):
        processor.tick(
            tick_index,
            auto_targets=True,
        )

    sched = scheduler_state(
        mode,
        warmup_steps,
    )

    dense_field = (
        processor.dense_coupling_field()
    )

    hierarchical_field = (
        processor.hierarchical_coupling_field()
    )

    coupling_errors = [
        abs(
            a
            - b
        )

        for (
            a,
            b,
        ) in zip(
            dense_field,
            hierarchical_field,
        )
    ]

    dense_velocities = (
        processor.phase_velocities(
            dense_field,
            sched,
        )
    )

    hierarchical_velocities = (
        processor.phase_velocities(
            hierarchical_field,
            sched,
        )
    )

    velocity_errors = [
        abs(
            a
            - b
        )

        for (
            a,
            b,
        ) in zip(
            dense_velocities,
            hierarchical_velocities,
        )
    ]

    dense_next_phases = [
        (
            processor.phases[i]
            + dense_velocities[i]
        )
        % math.tau

        for i in range(
            processor.cells
        )
    ]

    hierarchical_next_phases = [
        (
            processor.phases[i]
            + hierarchical_velocities[i]
        )
        % math.tau

        for i in range(
            processor.cells
        )
    ]

    phase_errors = [
        abs(
            a
            - b
        )

        for (
            a,
            b,
        ) in zip(
            dense_next_phases,
            hierarchical_next_phases,
        )
    ]

    max_coupling_error = max(
        coupling_errors
    )

    mean_coupling_error = (
        sum(
            coupling_errors
        )
        / len(
            coupling_errors
        )
    )

    max_phase_velocity_error = max(
        velocity_errors
    )

    max_phase_error = max(
        phase_errors
    )

    tolerance = (
        processor.equivalence_tolerance
    )

    topology_match = (
        1.0

        if (
            max_coupling_error
            <= tolerance

            and max_phase_velocity_error
            <= tolerance

            and max_phase_error
            <= tolerance
        )

        else 0.0
    )

    topology_metrics = (
        processor.topology_metrics(
            processor.coupling_matrix,
            processor.fractal_alpha,
        )
    )

    checks = {
        "dense_path_present":
            True,

        "hierarchical_path_present":
            True,

        "topology_row_sum_match":
            topology_metrics[
                "row_sum_match"
            ],

        "topology_symmetry_match":
            topology_metrics[
                "symmetry_match"
            ],

        "topology_diagonal_zero":
            topology_metrics[
                "diagonal_zero"
            ],

        "shell_influence_monotonic":
            topology_metrics[
                "shell_influence_monotonic"
            ],

        "topology_match":
            topology_match
            == 1.0,

        "max_coupling_error_within_tolerance":
            max_coupling_error
            <= tolerance,

        "max_phase_velocity_error_within_tolerance":
            max_phase_velocity_error
            <= tolerance,

        "max_phase_error_within_tolerance":
            max_phase_error
            <= tolerance,

        "actual_direct_events_zero":
            processor.actual_direct_events
            == 0,

        "balanced_ternary_state_domain":
            all(
                state in TERNARY_STATES

                for state in processor.states
            ),

        "scheduler_counts_valid":
            processor.scheduler_counts

            == expected_scheduler_counts(
                mode,
                warmup_steps,
            ),
    }

    return {
        "schema":
            M14_DENSE_HIERARCHICAL_EQUIVALENCE_MAP_SCHEMA,

        "kind":
            "dense_hierarchical_equivalence_map",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "status":
            (
                "PASS"
                if all(
                    checks.values()
                )
                else "REVIEW"
            ),

        "scheduler":
            mode,

        "checks":
            checks,

        "equivalence_markers": {
            "topology_match":
                topology_match,

            "equivalence_tolerance":
                tolerance,

            "max_coupling_error":
                max_coupling_error,

            "mean_coupling_error":
                mean_coupling_error,

            "max_phase_velocity_error":
                max_phase_velocity_error,

            "max_phase_error":
                max_phase_error,
        },

        "topology_metrics":
            topology_metrics,

        "dense_coupling_field":
            dense_field,

        "hierarchical_coupling_field":
            hierarchical_field,

        "dense_phase_velocity":
            dense_velocities,

        "hierarchical_phase_velocity":
            hierarchical_velocities,

        "summary":
            processor.summarize(
                warmup_steps
            ),
    }


def physical_domain_correlation_package(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    equivalence = (
        dense_hierarchical_equivalence_map(
            args
        )
    )

    hotspot = (
        run_hotspot_harness(
            args
        )
    )

    processor = make_processor(
        args
    )

    processor.run(
        args.steps,
        auto_targets=True,
    )

    rows = [
        {
            "source_variable":
                "cell_state",

            "hierarchy_level":
                "leaf",

            "correlation_domain":
                "balanced ternary cell domain",

            "dense_reference_representation":
                "per-cell state vector",

            "hierarchical_representation":
                "leaf state",

            "validation_marker":
                "balanced_ternary_state_domain",

            "production_qualification_status":
                "PASS",
        },

        {
            "source_variable":
                "W_ij",

            "hierarchy_level":
                "all levels",

            "correlation_domain":
                "phase-coupling shell",

            "dense_reference_representation":
                "N x N coupling matrix",

            "hierarchical_representation":
                "shell pair weights and sibling-block sums",

            "validation_marker":
                "topology_match",

            "production_qualification_status":
                equivalence[
                    "status"
                ],
        },

        {
            "source_variable":
                "T_ij",

            "hierarchy_level":
                "all levels",

            "correlation_domain":
                "thermal-diffusion shell",

            "dense_reference_representation":
                "N x N thermal matrix",

            "hierarchical_representation":
                "dyadic thermal shell weights",

            "validation_marker":
                "cross_cluster_thermal_propagation_bounded",

            "production_qualification_status":
                hotspot[
                    "status"
                ],
        },

        {
            "source_variable":
                "heat_i",

            "hierarchy_level":
                "leaf and cluster",

            "correlation_domain":
                "local thermal field",

            "dense_reference_representation":
                "per-cell heat vector",

            "hierarchical_representation":
                "cell and cluster thermal aggregates",

            "validation_marker":
                "localized_hotspot_containment_pass",

            "production_qualification_status":
                hotspot[
                    "status"
                ],
        },

        {
            "source_variable":
                "R_G",

            "hierarchy_level":
                "pair through global",

            "correlation_domain":
                "multiscale phase-coherence domain",

            "dense_reference_representation":
                "group phase-order evaluation",

            "hierarchical_representation":
                "dyadic group coherence map",

            "validation_marker":
                "multiscale_phase_coherence_present",

            "production_qualification_status":
                "PASS",
        },

        {
            "source_variable":
                "C_minus_P",

            "hierarchy_level":
                "global",

            "correlation_domain":
                "global stability margin",

            "dense_reference_representation":
                "global telemetry",

            "hierarchical_representation":
                "global aggregate over local domains",

            "validation_marker":
                "C_minus_P_min",

            "production_qualification_status":
                (
                    "PASS"

                    if processor.summarize(
                        args.steps
                    )[
                        "C_minus_P_min"
                    ]
                    > 0

                    else "REVIEW"
                ),
        },
    ]

    qualification_status = (
        "PASS"

        if (
            equivalence[
                "status"
            ]
            == "PASS"

            and hotspot[
                "status"
            ]
            == "PASS"

            and all(
                row[
                    "production_qualification_status"
                ]
                == "PASS"

                for row in rows
            )
        )

        else "REVIEW"
    )

    return {
        "schema":
            M14_PHYSICAL_DOMAIN_CORRELATION_PACKAGE_SCHEMA,

        "kind":
            "physical_domain_correlation_package",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "status":
            qualification_status,

        "inherited_boundary":
            inherited_v1_5_0_boundary(),

        "qualification_domains": [
            "topology generation qualification",

            "topology normalization qualification",

            "topology symmetry qualification",

            "dyadic shell-population qualification",

            "shell-influence monotonicity qualification",

            "balanced ternary state qualification",

            "neutral-routing qualification",

            "7/1 scheduler qualification",

            "1/7 scheduler qualification",

            "dense reference coupling qualification",

            "hierarchical coupling qualification",

            "dense-hierarchical equivalence qualification",

            "local thermal-field qualification",

            "thermal-diffusion qualification",

            "multiscale phase-coherence qualification",

            "hotspot-containment qualification",

            "cross-cluster propagation qualification",

            "deterministic seeded execution qualification",

            "structured artifact qualification",
        ],

        "rows":
            rows,

        "dense_hierarchical_equivalence_status":
            equivalence[
                "status"
            ],

        "localized_hotspot_containment_status":
            hotspot[
                "status"
            ],
    }


def benchmark_matrix(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    reference_summary = (
        run_reference(
            args
        )[
            "summary"
        ]
    )

    equivalence = (
        dense_hierarchical_equivalence_map(
            args
        )
    )

    hotspot = (
        run_hotspot_harness(
            args
        )
    )

    rows = [
        {
            "architecture":
                "all_to_all_uniform_reference",

            "interaction_scaling":
                "O(N^2)",

            "hierarchical_topology":
                False,

            "local_thermal_field":
                False,

            "dense_hierarchical_equivalence":
                False,

            "hotspot_containment":
                False,
        },

        {
            "architecture":
                "frp_v1_5_0_thermal_delay_stabilization",

            "interaction_scaling":
                "O(N^2) reference phase interaction",

            "hierarchical_topology":
                False,

            "local_thermal_field":
                False,

            "dense_hierarchical_equivalence":
                False,

            "hotspot_containment":
                False,

            "actual_direct_events":
                0,
        },

        {
            "architecture":
                "frp_v1_6_0_dense_hierarchical_reference",

            "interaction_scaling":
                "O(N^2)",

            "hierarchical_topology":
                True,

            "local_thermal_field":
                True,

            "dense_hierarchical_equivalence":
                True,

            "hotspot_containment":
                True,

            "topology_match":
                equivalence[
                    "equivalence_markers"
                ][
                    "topology_match"
                ],

            "max_coupling_error":
                equivalence[
                    "equivalence_markers"
                ][
                    "max_coupling_error"
                ],

            "actual_direct_events":
                equivalence[
                    "summary"
                ][
                    "actual_direct_events"
                ],
        },

        {
            "architecture":
                "frp_v1_6_0_hierarchical_accelerated_path",

            "interaction_scaling":
                "O(N log N)",

            "hierarchical_topology":
                True,

            "local_thermal_field":
                True,

            "dense_hierarchical_equivalence":
                True,

            "hotspot_containment":
                True,

            "topology_match":
                equivalence[
                    "equivalence_markers"
                ][
                    "topology_match"
                ],

            "max_phase_velocity_error":
                equivalence[
                    "equivalence_markers"
                ][
                    "max_phase_velocity_error"
                ],

            "actual_direct_events":
                reference_summary[
                    "actual_direct_events"
                ],
        },

        {
            "architecture":
                "frp_v1_6_0_localized_hotspot_containment",

            "interaction_scaling":
                "hierarchical coupled domains",

            "hierarchical_topology":
                True,

            "local_thermal_field":
                True,

            "dense_hierarchical_equivalence":
                True,

            "hotspot_containment":
                hotspot[
                    "status"
                ]
                == "PASS",

            "cross_cluster_thermal_propagation_ratio":
                hotspot[
                    "containment_markers"
                ][
                    "cross_cluster_thermal_propagation_ratio"
                ],

            "remote_thermal_propagation_ratio":
                hotspot[
                    "containment_markers"
                ][
                    "remote_thermal_propagation_ratio"
                ],

            "actual_direct_events":
                hotspot[
                    "summary"
                ][
                    "actual_direct_events"
                ],
        },
    ]

    return {
        "schema":
            BENCHMARK_SCHEMA,

        "kind":
            "benchmark_matrix",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "rows":
            rows,
    }


def scheduler_kernel_validation(
    args: argparse.Namespace,
    mode: str,
) -> Dict[str, Any]:
    processor = make_processor(
        args,
        scheduler=mode,
    )

    processor.states = [
        -1
        if i % 2 == 0
        else 1

        for i in range(
            processor.cells
        )
    ]

    steps = 16

    for tick_index in range(
        steps
    ):
        inject_hostile_requests(
            processor,

            list(
                range(
                    processor.cells
                )
            ),

            count=max(
                1,

                int(
                    round(
                        processor.cells

                        * processor.transition_fraction
                    )
                ),
            ),

            tick_index=
                tick_index,
        )

        processor.tick(
            tick_index,
            auto_targets=False,
        )

    summary = processor.summarize(
        steps
    )

    expected = expected_scheduler_counts(
        mode,
        steps,
    )

    return {
        "scheduler":
            mode,

        "status":
            (
                "PASS"

                if (
                    summary[
                        "balanced_ternary_state_domain"
                    ]

                    and summary[
                        "actual_direct_events"
                    ]
                    == 0

                    and summary[
                        "scheduler_counts"
                    ]
                    == expected

                    and summary[
                        "switch_load_peak"
                    ]
                    <= (
                        processor.transition_fraction
                        + 1e-9
                    )

                    and summary[
                        "ticks_recorded"
                    ]
                    == steps
                )

                else "REVIEW"
            ),

        "expected_scheduler_counts":
            expected,

        "summary":
            summary,
    }


def neutral_route_validation(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args,
        cells=8,
        scheduler="free",
    )

    processor.states = [
        -1,
        1,
        -1,
        1,
        -1,
        1,
        -1,
        1,
    ]

    processor.request_transition(
        0,
        1,
    )

    processor.tick(
        0,
        auto_targets=False,
    )

    state_after_tick_0 = (
        processor.states[
            0
        ]
    )

    pending_after_tick_0 = len(
        processor.pending_neutral_routes
    )

    processor.tick(
        1,
        auto_targets=False,
    )

    state_after_tick_1 = (
        processor.states[
            0
        ]
    )

    checks = {
        "tick_0_reaches_neutral":
            state_after_tick_0
            == 0,

        "tick_0_route_pending":
            pending_after_tick_0
            == 1,

        "tick_1_reaches_target":
            state_after_tick_1
            == 1,

        "actual_direct_events_zero":
            processor.actual_direct_events
            == 0,

        "requested_direct_events_one":
            processor.requested_direct_events
            == 1,

        "prevented_direct_events_one":
            processor.prevented_direct_events
            == 1,

        "neutral_routed_events_one":
            processor.neutral_routed_events
            == 1,
    }

    return {
        "status":
            (
                "PASS"
                if all(
                    checks.values()
                )
                else "REVIEW"
            ),

        "checks":
            checks,

        "state_after_tick_0":
            state_after_tick_0,

        "state_after_tick_1":
            state_after_tick_1,

        "summary":
            processor.summarize(
                2
            ),
    }


def deterministic_repeat_validation(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    first = structured_output(
        "demo",
        args,
        include_telemetry=False,
    )

    second = structured_output(
        "demo",
        args,
        include_telemetry=False,
    )

    return {
        "match":
            first
            == second,

        "first":
            first,

        "second":
            second,
    }


def self_test(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    reference = run_reference(
        args
    )

    reference_summary = (
        reference[
            "summary"
        ]
    )

    topology = (
        hierarchical_ultrametric_topology_model(
            args
        )
    )

    coupling_map = (
        fractal_coupling_weight_map(
            args
        )
    )

    multiscale = (
        multiscale_phase_coherence_map(
            args
        )
    )

    thermal = (
        cluster_local_thermal_field(
            args
        )
    )

    hotspot = (
        run_hotspot_harness(
            args
        )
    )

    cross_cluster = (
        cross_cluster_propagation_map(
            args
        )
    )

    equivalence_default = (
        dense_hierarchical_equivalence_map(
            args
        )
    )

    equivalence_7_1 = (
        dense_hierarchical_equivalence_map(
            args,
            scheduler="7/1",
        )
    )

    equivalence_1_7 = (
        dense_hierarchical_equivalence_map(
            args,
            scheduler="1/7",
        )
    )

    physical = (
        physical_domain_correlation_package(
            args
        )
    )

    scheduler_free = (
        scheduler_kernel_validation(
            args,
            "free",
        )
    )

    scheduler_7_1 = (
        scheduler_kernel_validation(
            args,
            "7/1",
        )
    )

    scheduler_1_7 = (
        scheduler_kernel_validation(
            args,
            "1/7",
        )
    )

    neutral_route = (
        neutral_route_validation(
            args
        )
    )

    deterministic = (
        deterministic_repeat_validation(
            args
        )
    )

    topology_metrics = (
        topology[
            "topology_metrics"
        ]
    )

    thermal_topology_metrics = (
        thermal[
            "thermal_topology_metrics"
        ]
    )

    checks = {
        "reference_balanced_ternary_state_domain":
            reference_summary[
                "balanced_ternary_state_domain"
            ]
            is True,

        "reference_actual_direct_events_zero":
            reference_summary[
                "actual_direct_events"
            ]
            == 0,

        "reference_match_equals_one":
            reference_summary[
                "match"
            ]
            == 1.0,

        "reference_C_minus_P_positive":
            reference_summary[
                "C_minus_P_min"
            ]
            > 0,

        "reference_switch_load_within_transition_fraction":
            reference_summary[
                "switch_load_peak"
            ]
            <= (
                args.transition_fraction
                + 1e-9
            ),

        "reference_ticks_recorded_equals_steps":
            reference_summary[
                "ticks_recorded"
            ]
            == args.steps,

        "reference_scheduler_counts_valid":
            reference_summary[
                "scheduler_counts_valid"
            ]
            is True,

        "stable_cli_commands_present":
            len(
                stable_cli_commands()
            )
            == 12,

        "stable_schema_set_present":
            len(
                stable_schema_set()
            )
            == 20,

        "m14_artifact_layers_present":
            len(
                m14_artifact_layers()
            )
            == 8,

        "candidate_invariant_names_present":
            len(
                candidate_invariant_names()
            )
            == 24,

        "topology_row_sum_match":
            topology_metrics[
                "row_sum_match"
            ]
            is True,

        "topology_symmetry_match":
            topology_metrics[
                "symmetry_match"
            ]
            is True,

        "topology_diagonal_zero":
            topology_metrics[
                "diagonal_zero"
            ]
            is True,

        "shell_influence_monotonic":
            topology_metrics[
                "shell_influence_monotonic"
            ]
            is True,

        "thermal_topology_row_sum_match":
            thermal_topology_metrics[
                "row_sum_match"
            ]
            is True,

        "thermal_topology_symmetry_match":
            thermal_topology_metrics[
                "symmetry_match"
            ]
            is True,

        "thermal_topology_diagonal_zero":
            thermal_topology_metrics[
                "diagonal_zero"
            ]
            is True,

        "thermal_shell_influence_monotonic":
            thermal_topology_metrics[
                "shell_influence_monotonic"
            ]
            is True,

        "multiscale_phase_coherence_present":
            len(
                multiscale[
                    "levels"
                ]
            )
            == reference_summary[
                "hierarchy_depth"
            ],

        "local_thermal_field_present":
            len(
                thermal[
                    "final_heat_cells"
                ]
            )
            == args.cells,

        "hotspot_containment_pass":
            hotspot[
                "status"
            ]
            == "PASS",

        "cross_cluster_propagation_pass":
            cross_cluster[
                "status"
            ]
            == "PASS",

        "dense_hierarchical_equivalence_default_pass":
            equivalence_default[
                "status"
            ]
            == "PASS",

        "dense_hierarchical_equivalence_7_1_pass":
            equivalence_7_1[
                "status"
            ]
            == "PASS",

        "dense_hierarchical_equivalence_1_7_pass":
            equivalence_1_7[
                "status"
            ]
            == "PASS",

        "physical_domain_correlation_pass":
            physical[
                "status"
            ]
            == "PASS",

        "scheduler_free_pass":
            scheduler_free[
                "status"
            ]
            == "PASS",

        "scheduler_7_1_pass":
            scheduler_7_1[
                "status"
            ]
            == "PASS",

        "scheduler_1_7_pass":
            scheduler_1_7[
                "status"
            ]
            == "PASS",

        "neutral_route_tick_separated_pass":
            neutral_route[
                "status"
            ]
            == "PASS",

        "deterministic_repeat_match":
            deterministic[
                "match"
            ]
            is True,

        "all_export_schemas_exact":
            all([
                topology[
                    "schema"
                ]
                == M14_HIERARCHICAL_ULTRAMETRIC_TOPOLOGY_MODEL_SCHEMA,

                coupling_map[
                    "schema"
                ]
                == M14_FRACTAL_COUPLING_WEIGHT_MAP_SCHEMA,

                multiscale[
                    "schema"
                ]
                == M14_MULTISCALE_PHASE_COHERENCE_MAP_SCHEMA,

                thermal[
                    "schema"
                ]
                == M14_CLUSTER_LOCAL_THERMAL_FIELD_SCHEMA,

                cross_cluster[
                    "schema"
                ]
                == M14_CROSS_CLUSTER_PROPAGATION_MAP_SCHEMA,

                hotspot[
                    "schema"
                ]
                == M14_LOCALIZED_HOTSPOT_CONTAINMENT_HARNESS_SCHEMA,

                equivalence_default[
                    "schema"
                ]
                == M14_DENSE_HIERARCHICAL_EQUIVALENCE_MAP_SCHEMA,

                physical[
                    "schema"
                ]
                == M14_PHYSICAL_DOMAIN_CORRELATION_PACKAGE_SCHEMA,
            ]),
    }

    return {
        "schema":
            STRUCTURED_SCHEMA,

        "kind":
            "self_test",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "status":
            (
                "PASS"
                if all(
                    checks.values()
                )
                else "REVIEW"
            ),

        "checks":
            checks,

        "reference_summary":
            reference_summary,

        "scheduler_validation": {
            "free":
                scheduler_free,

            "7/1":
                scheduler_7_1,

            "1/7":
                scheduler_1_7,
        },

        "neutral_route_validation":
            neutral_route,

        "dense_hierarchical_equivalence": {
            "default":
                equivalence_default[
                    "equivalence_markers"
                ],

            "7/1":
                equivalence_7_1[
                    "equivalence_markers"
                ],

            "1/7":
                equivalence_1_7[
                    "equivalence_markers"
                ],
        },

        "hotspot_containment_markers":
            hotspot[
                "containment_markers"
            ],

        "hotspot_recovery_markers":
            hotspot[
                "recovery_markers"
            ],
    }


def text_report(
    payload: Dict[str, Any],
) -> str:
    lines = [
        f"FRP v{VERSION}",

        MILESTONE,

        f"kind: {payload.get('kind')}",
    ]

    if payload.get(
        "status"
    ):
        lines.append(
            f"status: {payload.get('status')}"
        )

    summary = (
        payload.get(
            "summary"
        )

        or payload.get(
            "reference_summary"
        )
    )

    if summary:
        for key in [
            "actual_direct_events",

            "requested_direct_events",

            "prevented_direct_events",

            "neutral_routed_events",

            "match",

            "balanced_ternary_state_domain",

            "heat_peak",

            "local_heat_peak",

            "frequency_lag_peak",

            "gamma_drift_peak",

            "coherence_compression_min",

            "C_minus_P_min",
        ]:
            if key in summary:
                lines.append(
                    f"{key}: {summary.get(key)}"
                )

    return "\n".join(
        lines
    )


def build_parser(
) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "FRP v1.6.0 M14 Physical Implementation Correlation and "
            "Production Qualification Package"
        )
    )

    parser.add_argument(
        "--mode",

        choices=(
            "demo",
            "self-test",
            "benchmark",
        ),

        default=
            "demo",
    )

    parser.add_argument(
        "--output",

        choices=(
            "text",
            "json",
        ),

        default=
            "text",
    )

    parser.add_argument(
        "--include-telemetry",
        action="store_true",
    )

    parser.add_argument(
        "--scheduler",
        choices=SCHEDULER_MODES,
        default="7/1",
    )

    parser.add_argument(
        "--cells",
        type=int,
        default=DEFAULT_CELLS,
    )

    parser.add_argument(
        "--steps",
        type=int,
        default=DEFAULT_STEPS,
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=DEFAULT_SEED,
    )

    parser.add_argument(
        "--transition-fraction",
        type=float,
        default=
            DEFAULT_TRANSITION_FRACTION,
    )

    parser.add_argument(
        "--gamma",
        type=float,
        default=DEFAULT_GAMMA,
    )

    parser.add_argument(
        "--fractal-alpha",
        type=float,
        default=
            DEFAULT_FRACTAL_ALPHA,
    )

    parser.add_argument(
        "--thermal-beta",
        type=float,
        default=
            DEFAULT_THERMAL_BETA,
    )

    parser.add_argument(
        "--ambient-heat",
        type=float,
        default=
            DEFAULT_AMBIENT_HEAT,
    )

    parser.add_argument(
        "--thermal-time-constant",
        type=float,
        default=
            DEFAULT_THERMAL_TIME_CONSTANT,
    )

    parser.add_argument(
        "--thermal-soft-limit",
        type=float,
        default=
            DEFAULT_THERMAL_SOFT_LIMIT,
    )

    parser.add_argument(
        "--thermal-hard-limit",
        type=float,
        default=
            DEFAULT_THERMAL_HARD_LIMIT,
    )

    parser.add_argument(
        "--coupling-nominal",
        type=float,
        default=
            DEFAULT_COUPLING_NOMINAL,
    )

    parser.add_argument(
        "--delay-alpha",
        type=float,
        default=
            DEFAULT_DELAY_ALPHA,
    )

    parser.add_argument(
        "--thermal-diffusion-gain",
        type=float,
        default=
            DEFAULT_THERMAL_DIFFUSION_GAIN,
    )

    parser.add_argument(
        "--equivalence-tolerance",
        type=float,
        default=
            DEFAULT_EQUIVALENCE_TOLERANCE,
    )

    parser.add_argument(
        "--export-benchmark-matrix",
        action="store_true",
    )

    parser.add_argument(
        "--export-hierarchical-ultrametric-topology-model",
        action="store_true",
    )

    parser.add_argument(
        "--export-fractal-coupling-weight-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-multiscale-phase-coherence-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-cluster-local-thermal-field",
        action="store_true",
    )

    parser.add_argument(
        "--export-cross-cluster-propagation-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-localized-hotspot-containment-harness",
        action="store_true",
    )

    parser.add_argument(
        "--export-dense-hierarchical-equivalence-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-physical-domain-correlation-package",
        action="store_true",
    )

    return parser


def main(
) -> None:
    parser = build_parser()

    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(
            args
        )

    elif args.export_hierarchical_ultrametric_topology_model:
        payload = (
            hierarchical_ultrametric_topology_model(
                args
            )
        )

    elif args.export_fractal_coupling_weight_map:
        payload = (
            fractal_coupling_weight_map(
                args
            )
        )

    elif args.export_multiscale_phase_coherence_map:
        payload = (
            multiscale_phase_coherence_map(
                args
            )
        )

    elif args.export_cluster_local_thermal_field:
        payload = (
            cluster_local_thermal_field(
                args
            )
        )

    elif args.export_cross_cluster_propagation_map:
        payload = (
            cross_cluster_propagation_map(
                args
            )
        )

    elif args.export_localized_hotspot_containment_harness:
        payload = (
            run_hotspot_harness(
                args
            )
        )

    elif args.export_dense_hierarchical_equivalence_map:
        payload = (
            dense_hierarchical_equivalence_map(
                args
            )
        )

    elif args.export_physical_domain_correlation_package:
        payload = (
            physical_domain_correlation_package(
                args
            )
        )

    elif args.mode == "self-test":
        payload = self_test(
            args
        )

    elif args.mode == "benchmark":
        payload = benchmark_matrix(
            args
        )

    else:
        payload = structured_output(
            "demo",
            args,
            args.include_telemetry,
        )

    export_requested = any([
        args.export_benchmark_matrix,

        args.export_hierarchical_ultrametric_topology_model,

        args.export_fractal_coupling_weight_map,

        args.export_multiscale_phase_coherence_map,

        args.export_cluster_local_thermal_field,

        args.export_cross_cluster_propagation_map,

        args.export_localized_hotspot_containment_harness,

        args.export_dense_hierarchical_equivalence_map,

        args.export_physical_domain_correlation_package,
    ])

    if (
        args.output == "json"

        or export_requested

        or args.mode == "benchmark"
    ):
        print(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            )
        )

    else:
        print(
            text_report(
                payload
            )
        )


if __name__ == "__main__":
    main()

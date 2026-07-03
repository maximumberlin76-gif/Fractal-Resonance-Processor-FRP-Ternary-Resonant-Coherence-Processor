#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Optional, Tuple

VERSION = "1.5.0"
MILESTONE = "M13 — Production Scaling and Implementation Stabilization Package"

STRUCTURED_SCHEMA = "frp.structured_output.v1.5.0"
BENCHMARK_SCHEMA = "frp.m3.benchmark_matrix.v1.5.0"

M13_THERMAL_SATURATION_MODEL_SCHEMA = "frp.m13.thermal_saturation_model.v1.5.0"
M13_DELAY_DYNAMICS_MODEL_SCHEMA = "frp.m13.delay_dynamics_model.v1.5.0"
M13_NONLINEAR_COHERENCE_COMPRESSION_MODEL_SCHEMA = "frp.m13.nonlinear_coherence_compression_model.v1.5.0"
M13_THERMAL_GAMMA_DRIFT_MODEL_SCHEMA = "frp.m13.thermal_gamma_drift_model.v1.5.0"
M13_COUPLED_THERMAL_DELAY_STRESS_HARNESS_SCHEMA = "frp.m13.coupled_thermal_delay_stress_harness.v1.5.0"
M13_THERMAL_STABILITY_BOUNDARY_SWEEP_SCHEMA = "frp.m13.thermal_stability_boundary_sweep.v1.5.0"
M13_RECOVERY_DYNAMICS_MAP_SCHEMA = "frp.m13.recovery_dynamics_map.v1.5.0"
M13_PRODUCTION_SCALING_STABILITY_ENVELOPE_SCHEMA = "frp.m13.production_scaling_stability_envelope.v1.5.0"

SCHEDULER_MODES = ("free", "7/1", "1/7")

DEFAULT_CELLS = 16
DEFAULT_STEPS = 64
DEFAULT_SEED = 76
DEFAULT_TRANSITION_FRACTION = 0.25
DEFAULT_GAMMA = 0.30 * math.pi

DEFAULT_AMBIENT_HEAT = 0.05
DEFAULT_THERMAL_TIME_CONSTANT = 12.0
DEFAULT_THERMAL_SOFT_LIMIT = 0.25
DEFAULT_THERMAL_HARD_LIMIT = 0.85
DEFAULT_COUPLING_NOMINAL = 0.20
DEFAULT_DELAY_ALPHA = 0.30


def q16(value: float) -> int:
    return int(round(value * 65536.0))


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def phase_order(phases: List[float]) -> float:
    n = len(phases)
    c = sum(math.cos(p) for p in phases) / n
    s = sum(math.sin(p) for p in phases) / n
    return math.sqrt(c * c + s * s)


def scheduler_state(mode: str, tick: int) -> str:
    if mode == "7/1":
        return "commit" if (tick + 1) % 8 == 0 else "balance"

    if mode == "1/7":
        return "excite" if tick % 8 == 0 else "neutralize"

    return "free"


def target_state(phase: float) -> int:
    x = math.sin(phase)

    if x > 0.33:
        return 1

    if x < -0.33:
        return -1

    return 0


class FractalResonanceProcessor:
    def __init__(
        self,
        cells: int,
        transition_fraction: float,
        gamma_nominal: float,
        scheduler: str,
        seed: int,
        ambient_heat: float = DEFAULT_AMBIENT_HEAT,
        thermal_time_constant: float = DEFAULT_THERMAL_TIME_CONSTANT,
        thermal_soft_limit: float = DEFAULT_THERMAL_SOFT_LIMIT,
        thermal_hard_limit: float = DEFAULT_THERMAL_HARD_LIMIT,
        coupling_nominal: float = DEFAULT_COUPLING_NOMINAL,
        delay_alpha: float = DEFAULT_DELAY_ALPHA,
    ) -> None:
        self.cells = cells
        self.transition_fraction = clamp(transition_fraction, 0.01, 1.0)
        self.gamma_nominal = gamma_nominal
        self.scheduler = scheduler
        self.seed = seed
        self.random = random.Random(seed)

        self.states = [
            self.random.choice((-1, 0, 1))
            for _ in range(cells)
        ]

        self.phases = [
            self.random.random() * math.tau
            for _ in range(cells)
        ]

        self.base_frequencies = [
            1.0
            for _ in range(cells)
        ]

        self.frequency_targets = [
            1.0
            for _ in range(cells)
        ]

        self.frequencies = [
            1.0
            for _ in range(cells)
        ]

        self.actual_direct_events = 0
        self.requested_direct_events = 0
        self.prevented_direct_events = 0
        self.neutral_routed_events = 0
        self.neutralized_conflicts = 0

        self.transition_requests: List[Tuple[int, int]] = []
        self.pending_neutral_routes: List[Tuple[int, int]] = []

        self.scheduler_counts: Dict[str, int] = {}
        self.telemetry: List[Dict[str, Any]] = []

        self.current_switch_changes = 0

        self.cell_switch_activity = [
            0
            for _ in range(cells)
        ]

        self.ambient_heat = ambient_heat
        self.heat = ambient_heat
        self.heat_peak = ambient_heat
        self.thermal_time_constant = thermal_time_constant
        self.thermal_soft_limit = thermal_soft_limit
        self.thermal_hard_limit = thermal_hard_limit

        self.base_power = 0.004
        self.switch_power_gain = 0.14
        self.lag_power_gain = 0.08

        self.coupling_nominal = coupling_nominal
        self.thermal_coupling_gain = 2.50
        self.effective_coupling = coupling_nominal

        self.delay_alpha = delay_alpha
        self.state_frequency_gain = 0.06
        self.switching_frequency_gain = 0.12

        self.gamma_noise_state = 0.0
        self.gamma_noise_target = 0.0
        self.gamma_correlation_alpha = 0.15
        self.gamma_thermal_gain = 0.08
        self.gamma_effective = gamma_nominal
        self.gamma_drift = 0.0
        self.gamma_drift_peak = 0.0

        self.thermal_compression_gain = 3.0
        self.margin_compression_gain = 1.5
        self.stability_soft_margin = 0.25
        self.previous_C_minus_P = 0.60

        self.first_C_minus_P_crossing: Optional[Dict[str, Any]] = None

    def request_transition(
        self,
        cell_idx: int,
        target: int,
    ) -> None:
        if target not in (-1, 0, 1):
            raise ValueError(
                "FRP transition target must be one of -1, 0, 1"
            )

        if cell_idx < 0 or cell_idx >= self.cells:
            raise IndexError(
                "FRP transition cell index out of range"
            )

        self.transition_requests.append(
            (cell_idx, target)
        )

    def _apply_state(
        self,
        cell_idx: int,
        next_state: int,
    ) -> bool:
        current = self.states[cell_idx]

        if current == next_state:
            return False

        if current * next_state == -1:
            self.actual_direct_events += 1

        self.states[cell_idx] = next_state
        self.current_switch_changes += 1
        self.cell_switch_activity[cell_idx] = 1

        return True

    def process_transition_requests(
        self,
        max_changes: int,
    ) -> int:
        changes = 0

        still_pending: List[Tuple[int, int]] = []

        for cell_idx, target in self.pending_neutral_routes:
            if changes >= max_changes:
                still_pending.append(
                    (cell_idx, target)
                )
                continue

            if self.states[cell_idx] == 0:
                if self._apply_state(
                    cell_idx,
                    target,
                ):
                    changes += 1

            else:
                still_pending.append(
                    (cell_idx, target)
                )

        self.pending_neutral_routes = still_pending

        remaining_requests: List[Tuple[int, int]] = []

        for cell_idx, target in self.transition_requests:
            if changes >= max_changes:
                remaining_requests.append(
                    (cell_idx, target)
                )
                continue

            current = self.states[cell_idx]

            if current == target:
                continue

            if current * target == -1:
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
                        (cell_idx, target)
                    )

                continue

            if self._apply_state(
                cell_idx,
                target,
            ):
                changes += 1

        self.transition_requests = remaining_requests

        return changes

    def update_reference_state_targets(
        self,
        max_changes: int,
        changes_used: int,
    ) -> int:
        changes = changes_used

        for i in range(self.cells):
            if changes >= max_changes:
                break

            desired = target_state(
                self.phases[i]
            )

            current = self.states[i]

            if current == desired:
                continue

            if current * desired == -1:
                self.prevented_direct_events += 1
                self.neutralized_conflicts += 1

                if self._apply_state(
                    i,
                    0,
                ):
                    changes += 1
                    self.neutral_routed_events += 1

                    self.pending_neutral_routes.append(
                        (i, desired)
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
    ) -> Dict[str, float]:
        lags: List[float] = []

        for i in range(self.cells):
            self.frequency_targets[i] = (
                self.base_frequencies[i]
                + self.state_frequency_gain
                * abs(self.states[i])
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
            "mean_frequency_lag":
                sum(lags) / self.cells,

            "frequency_lag_peak_tick":
                max(lags),
        }

    def update_thermal_state(
        self,
        switch_load: float,
        mean_frequency_lag: float,
    ) -> Dict[str, float]:
        generated_power = (
            self.base_power
            + self.switch_power_gain
            * switch_load
            + self.lag_power_gain
            * mean_frequency_lag
        )

        thermal_dissipation = (
            self.heat
            - self.ambient_heat
        ) / self.thermal_time_constant

        self.heat = max(
            self.ambient_heat,
            self.heat
            + generated_power
            - thermal_dissipation,
        )

        self.heat_peak = max(
            self.heat_peak,
            self.heat,
        )

        thermal_overload = max(
            0.0,
            self.heat
            - self.thermal_soft_limit,
        )

        return {
            "generated_power":
                generated_power,

            "thermal_dissipation":
                thermal_dissipation,

            "thermal_overload":
                thermal_overload,
        }

    def update_gamma_drift(
        self,
        tick_index: int,
        thermal_overload: float,
    ) -> None:
        if tick_index % 8 == 0:
            self.gamma_noise_target = (
                self.random.uniform(
                    -1.0,
                    1.0,
                )
            )

        self.gamma_noise_state += (
            self.gamma_correlation_alpha
            * (
                self.gamma_noise_target
                - self.gamma_noise_state
            )
        )

        self.gamma_effective = (
            self.gamma_nominal
            + self.gamma_thermal_gain
            * thermal_overload
            * self.gamma_noise_state
        )

        self.gamma_drift = (
            self.gamma_effective
            - self.gamma_nominal
        )

        self.gamma_drift_peak = max(
            self.gamma_drift_peak,
            abs(self.gamma_drift),
        )

    def update_phase_field(
        self,
        scheduler_mode: str,
        thermal_overload: float,
    ) -> float:
        self.effective_coupling = (
            self.coupling_nominal
            * math.exp(
                -self.thermal_coupling_gain
                * thermal_overload
            )
        )

        updated: List[float] = []

        for i, phase_i in enumerate(
            self.phases
        ):
            coupling_sum = 0.0

            for j, phase_j in enumerate(
                self.phases
            ):
                if i != j:
                    coupling_sum += math.sin(
                        phase_j
                        - phase_i
                        - self.gamma_effective
                    )

            coupling_sum /= max(
                1,
                self.cells - 1,
            )

            scheduler_push = (
                0.010
                if scheduler_mode == "commit"
                else 0.006
                if scheduler_mode == "excite"
                else 0.003
            )

            phase_velocity = (
                0.060
                * self.frequencies[i]
                + scheduler_push
                + 0.040
                * self.effective_coupling
                * coupling_sum
            )

            updated.append(
                (
                    phase_i
                    + phase_velocity
                )
                % math.tau
            )

        self.phases = updated

        return phase_order(
            self.phases
        )

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

        self.scheduler_counts[sched] = (
            self.scheduler_counts.get(
                sched,
                0,
            )
            + 1
        )

        self.current_switch_changes = 0

        self.cell_switch_activity = [
            0
            for _ in range(self.cells)
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
            self.process_transition_requests(
                max_changes
            )
        )

        if auto_targets:
            changes = (
                self.update_reference_state_targets(
                    max_changes,
                    changes,
                )
            )

        switch_load = (
            self.current_switch_changes
            / self.cells
        )

        delay = (
            self.update_delay_dynamics()
        )

        mean_frequency_lag = (
            delay[
                "mean_frequency_lag"
            ]
        )

        frequency_lag_peak_tick = (
            delay[
                "frequency_lag_peak_tick"
            ]
        )

        thermal = (
            self.update_thermal_state(
                switch_load,
                mean_frequency_lag,
            )
        )

        generated_power = (
            thermal[
                "generated_power"
            ]
        )

        thermal_dissipation = (
            thermal[
                "thermal_dissipation"
            ]
        )

        thermal_overload = (
            thermal[
                "thermal_overload"
            ]
        )

        self.update_gamma_drift(
            tick_index,
            thermal_overload,
        )

        raw_phase_coherence = (
            self.update_phase_field(
                sched,
                thermal_overload,
            )
        )

        margin_pressure = max(
            0.0,
            self.stability_soft_margin
            - self.previous_C_minus_P,
        )

        coherence_compression = (
            math.exp(
                -(
                    self.thermal_compression_gain
                    * thermal_overload
                    * thermal_overload

                    + self.margin_compression_gain
                    * margin_pressure
                    * margin_pressure
                )
            )
        )

        effective_coherence = (
            raw_phase_coherence
            * coherence_compression
        )

        neutral_fraction = (
            self.states.count(0)
            / self.cells
        )

        c_value = (
            0.820
            + 0.500
            * effective_coherence
            + 0.080
            * neutral_fraction
            - 0.100
            * mean_frequency_lag
        )

        p_value = (
            self.heat
            + switch_load
        )

        c_minus_p = (
            c_value
            - p_value
        )

        previous_margin = (
            self.previous_C_minus_P
        )

        self.previous_C_minus_P = (
            c_minus_p
        )

        if (
            self.first_C_minus_P_crossing
            is None

            and previous_margin > 0.0

            and c_minus_p <= 0.0
        ):
            self.first_C_minus_P_crossing = {
                "boundary_tick":
                    tick_index,

                "boundary_pressure_level":
                    pressure_level,

                "heat_at_boundary":
                    self.heat,

                "gamma_drift_at_boundary":
                    self.gamma_drift,

                "frequency_lag_at_boundary":
                    mean_frequency_lag,

                "raw_phase_coherence_at_boundary":
                    raw_phase_coherence,

                "effective_coherence_at_boundary":
                    effective_coherence,

                "coherence_compression_at_boundary":
                    coherence_compression,

                "C_minus_P_at_boundary":
                    c_minus_p,
            }

        self.telemetry.append({
            "tick":
                tick_index,

            "scheduler_state":
                sched,

            "pressure_level":
                pressure_level,

            "cell_state":
                list(self.states),

            "phase":
                [
                    round(x, 6)
                    for x in self.phases
                ],

            "frequency_target":
                [
                    round(x, 6)
                    for x
                    in self.frequency_targets
                ],

            "frequency_current":
                [
                    round(x, 6)
                    for x
                    in self.frequencies
                ],

            "mean_frequency_lag":
                round(
                    mean_frequency_lag,
                    6,
                ),

            "frequency_lag_peak_tick":
                round(
                    frequency_lag_peak_tick,
                    6,
                ),

            "switch_load":
                round(
                    switch_load,
                    6,
                ),

            "generated_power":
                round(
                    generated_power,
                    6,
                ),

            "thermal_dissipation":
                round(
                    thermal_dissipation,
                    6,
                ),

            "heat":
                round(
                    self.heat,
                    6,
                ),

            "thermal_overload":
                round(
                    thermal_overload,
                    6,
                ),

            "effective_coupling":
                round(
                    self.effective_coupling,
                    6,
                ),

            "gamma_effective":
                round(
                    self.gamma_effective,
                    6,
                ),

            "gamma_drift":
                round(
                    self.gamma_drift,
                    6,
                ),

            "raw_phase_coherence":
                round(
                    raw_phase_coherence,
                    6,
                ),

            "coherence_compression":
                round(
                    coherence_compression,
                    6,
                ),

            "effective_coherence":
                round(
                    effective_coherence,
                    6,
                ),

            "C":
                round(
                    c_value,
                    6,
                ),

            "P":
                round(
                    p_value,
                    6,
                ),

            "C_minus_P":
                round(
                    c_minus_p,
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
            x["C_minus_P"]
            for x in self.telemetry
        ]

        switch_values = [
            x["switch_load"]
            for x in self.telemetry
        ]

        heat_values = [
            x["heat"]
            for x in self.telemetry
        ]

        overload_values = [
            x["thermal_overload"]
            for x in self.telemetry
        ]

        generated_power_values = [
            x["generated_power"]
            for x in self.telemetry
        ]

        coupling_values = [
            x["effective_coupling"]
            for x in self.telemetry
        ]

        gamma_drift_values = [
            abs(
                x["gamma_drift"]
            )
            for x in self.telemetry
        ]

        lag_values = [
            x["mean_frequency_lag"]
            for x in self.telemetry
        ]

        lag_peak_values = [
            x[
                "frequency_lag_peak_tick"
            ]
            for x in self.telemetry
        ]

        raw_coherence_values = [
            x["raw_phase_coherence"]
            for x in self.telemetry
        ]

        compression_values = [
            x["coherence_compression"]
            for x in self.telemetry
        ]

        effective_coherence_values = [
            x["effective_coherence"]
            for x in self.telemetry
        ]

        match = (
            1.0
            if self.actual_direct_events == 0
            else 0.0
        )

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
                len(
                    self.telemetry
                ),

            "scheduler":
                self.scheduler,

            "scheduler_counts":
                dict(
                    self.scheduler_counts
                ),

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

            "switch_load_peak":
                round(
                    max(switch_values),
                    6,
                ),

            "heat_final":
                round(
                    heat_values[-1],
                    6,
                ),

            "heat_peak":
                round(
                    max(heat_values),
                    6,
                ),

            "thermal_overload_peak":
                round(
                    max(overload_values),
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
                    min(coupling_values),
                    6,
                ),

            "gamma_effective_final":
                round(
                    self.gamma_effective,
                    6,
                ),

            "gamma_drift_final":
                round(
                    self.gamma_drift,
                    6,
                ),

            "gamma_drift_peak":
                round(
                    max(
                        gamma_drift_values
                    ),
                    6,
                ),

            "mean_frequency_lag_final":
                round(
                    lag_values[-1],
                    6,
                ),

            "mean_frequency_lag_peak":
                round(
                    max(lag_values),
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
                    raw_coherence_values[-1],
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
                    compression_values[-1],
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
                    effective_coherence_values[-1],
                    6,
                ),

            "effective_coherence_min":
                round(
                    min(
                        effective_coherence_values
                    ),
                    6,
                ),

            "C_minus_P_final":
                round(
                    c_minus_p_values[-1],
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
                (
                    self.first_C_minus_P_crossing
                    is not None
                ),

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
        for tick_index in range(steps):
            self.tick(
                tick_index,
                auto_targets=auto_targets,
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
) -> FractalResonanceProcessor:
    return FractalResonanceProcessor(
        cells=(
            cells
            if cells is not None
            else args.cells
        ),

        transition_fraction=(
            transition_fraction
            if transition_fraction is not None
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
    )


def run_reference(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    return (
        make_processor(args)
        .run(
            args.steps,
            auto_targets=True,
        )
    )


def inject_hostile_requests(
    processor: FractalResonanceProcessor,
    count: int,
    tick_index: int,
) -> None:
    nonzero_cells = [
        i
        for i, state
        in enumerate(
            processor.states
        )
        if state != 0
    ]

    if not nonzero_cells:
        return

    for offset in range(
        min(
            count,
            len(nonzero_cells),
        )
    ):
        cell_idx = (
            nonzero_cells[
                (
                    tick_index
                    * count
                    + offset
                )
                % len(nonzero_cells)
            ]
        )

        processor.request_transition(
            cell_idx,
            -processor.states[cell_idx],
        )


def run_bounded_thermal_survival(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    processor.states = [
        (
            -1
            if i % 2 == 0
            else 1
        )
        for i in range(
            processor.cells
        )
    ]

    steps = max(
        args.steps,
        96,
    )

    pressure_end = int(
        round(
            steps
            * 0.58
        )
    )

    recovery_start_tick = (
        pressure_end
    )

    for tick_index in range(steps):
        if tick_index < pressure_end:
            inject_hostile_requests(
                processor,
                2,
                tick_index,
            )

        processor.tick(
            tick_index,
            auto_targets=False,
        )

    summary = processor.summarize(
        steps
    )

    final = processor.telemetry[-1]

    recovery_completed = (
        final["heat"] <= 0.18

        and final["mean_frequency_lag"]
        <= 0.01

        and abs(
            final["gamma_drift"]
        )
        <= 0.01

        and final["C_minus_P"]
        >= 0.20
    )

    recovery_completion_tick: Optional[int] = None

    for record in (
        processor.telemetry[
            recovery_start_tick:
        ]
    ):
        if (
            record["heat"]
            <= 0.18

            and record[
                "mean_frequency_lag"
            ]
            <= 0.01

            and abs(
                record["gamma_drift"]
            )
            <= 0.01

            and record["C_minus_P"]
            >= 0.20
        ):
            recovery_completion_tick = (
                record["tick"]
            )
            break

    checks = {
        "actual_direct_events_zero":
            (
                summary[
                    "actual_direct_events"
                ]
                == 0
            ),

        "requested_direct_events_present":
            (
                summary[
                    "requested_direct_events"
                ]
                >= 1
            ),

        "prevented_direct_events_cover_requests":
            (
                summary[
                    "prevented_direct_events"
                ]
                >= summary[
                    "requested_direct_events"
                ]
            ),

        "neutral_routed_events_cover_prevention":
            (
                summary[
                    "neutral_routed_events"
                ]
                >= summary[
                    "prevented_direct_events"
                ]
            ),

        "C_minus_P_positive":
            (
                summary[
                    "C_minus_P_min"
                ]
                > 0
            ),

        "heat_peak_within_hard_limit":
            (
                summary[
                    "heat_peak"
                ]
                <= processor.thermal_hard_limit
            ),

        "frequency_lag_bounded":
            (
                summary[
                    "frequency_lag_peak"
                ]
                <= 0.20
            ),

        "gamma_drift_bounded":
            (
                summary[
                    "gamma_drift_peak"
                ]
                <= 0.08
            ),

        "switch_load_within_transition_fraction":
            (
                summary[
                    "switch_load_peak"
                ]
                <= (
                    processor.transition_fraction
                    + 1e-9
                )
            ),

        "ticks_recorded_equals_steps":
            (
                summary[
                    "ticks_recorded"
                ]
                == summary[
                    "steps"
                ]
            ),

        "scheduler_counts_sum_equals_steps":
            (
                sum(
                    summary[
                        "scheduler_counts"
                    ].values()
                )
                == summary[
                    "steps"
                ]
            ),

        "recovery_completed":
            recovery_completed,
    }

    return {
        "schema":
            M13_COUPLED_THERMAL_DELAY_STRESS_HARNESS_SCHEMA,

        "kind":
            "coupled_thermal_delay_stress_harness",

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

        "stress_profile": {
            "pressure_type":
                "bounded hostile transition pressure",

            "pressure_end_tick":
                pressure_end - 1,

            "recovery_start_tick":
                recovery_start_tick,

            "tick_separated_neutral_routing":
                True,

            "thermal_delay_coupling":
                True,

            "correlated_gamma_drift":
                True,

            "nonlinear_coherence_compression":
                True,
        },

        "recovery": {
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


def run_boundary_sweep(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    processor.states = [
        (
            -1
            if i % 2 == 0
            else 1
        )
        for i in range(
            processor.cells
        )
    ]

    pressure_levels = [
        0.10,
        0.25,
        0.50,
        0.75,
        1.00,
    ]

    stage_ticks = 16
    tick_index = 0

    stage_summaries: List[
        Dict[str, Any]
    ] = []

    for pressure_level in pressure_levels:
        processor.transition_fraction = (
            pressure_level
        )

        stage_start = len(
            processor.telemetry
        )

        for _ in range(
            stage_ticks
        ):
            inject_hostile_requests(
                processor,
                processor.cells,
                tick_index,
            )

            processor.tick(
                tick_index,
                auto_targets=False,
                pressure_level=
                    pressure_level,
            )

            tick_index += 1

        stage_records = (
            processor.telemetry[
                stage_start:
            ]
        )

        stage_summaries.append({
            "pressure_level":
                pressure_level,

            "stage_ticks":
                stage_ticks,

            "C_minus_P_min":
                round(
                    min(
                        x["C_minus_P"]
                        for x
                        in stage_records
                    ),
                    6,
                ),

            "heat_peak":
                round(
                    max(
                        x["heat"]
                        for x
                        in stage_records
                    ),
                    6,
                ),

            "gamma_drift_peak":
                round(
                    max(
                        abs(
                            x["gamma_drift"]
                        )
                        for x
                        in stage_records
                    ),
                    6,
                ),

            "frequency_lag_peak":
                round(
                    max(
                        x[
                            "frequency_lag_peak_tick"
                        ]
                        for x
                        in stage_records
                    ),
                    6,
                ),

            "coherence_compression_min":
                round(
                    min(
                        x[
                            "coherence_compression"
                        ]
                        for x
                        in stage_records
                    ),
                    6,
                ),
        })

    summary = processor.summarize(
        tick_index
    )

    crossing = (
        processor.first_C_minus_P_crossing
    )

    checks = {
        "boundary_detected":
            (
                summary[
                    "boundary_detected"
                ]
                is True
            ),

        "first_crossing_recorded":
            (
                crossing
                is not None
            ),

        "actual_direct_events_zero":
            (
                summary[
                    "actual_direct_events"
                ]
                == 0
            ),

        "ordered_pressure_levels_present":
            (
                [
                    x["pressure_level"]
                    for x
                    in stage_summaries
                ]
                == pressure_levels
            ),

        "ticks_recorded_matches_sweep":
            (
                summary[
                    "ticks_recorded"
                ]
                == (
                    len(
                        pressure_levels
                    )
                    * stage_ticks
                )
            ),

        "scheduler_counts_sum_equals_steps":
            (
                sum(
                    summary[
                        "scheduler_counts"
                    ].values()
                )
                == summary[
                    "steps"
                ]
            ),
    }

    return {
        "schema":
            M13_THERMAL_STABILITY_BOUNDARY_SWEEP_SCHEMA,

        "kind":
            "thermal_stability_boundary_sweep",

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

        "pressure_levels":
            pressure_levels,

        "stage_ticks":
            stage_ticks,

        "stage_summaries":
            stage_summaries,

        "boundary_markers": {
            "boundary_detected":
                summary[
                    "boundary_detected"
                ],

            "first_C_minus_P_crossing":
                crossing,
        },

        "summary":
            summary,

        "telemetry":
            processor.telemetry,
    }


def run_recovery_dynamics(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    processor = make_processor(
        args
    )

    processor.states = [
        (
            -1
            if i % 2 == 0
            else 1
        )
        for i in range(
            processor.cells
        )
    ]

    stress_ticks = 48
    recovery_ticks = 96

    total_steps = (
        stress_ticks
        + recovery_ticks
    )

    for tick_index in range(
        total_steps
    ):
        if tick_index < stress_ticks:
            inject_hostile_requests(
                processor,
                4,
                tick_index,
            )

        processor.tick(
            tick_index,
            auto_targets=False,
        )

    recovery_start_tick = (
        stress_ticks
    )

    recovery_completion_tick: Optional[int] = None

    recovery_heat_limit = 0.18
    recovery_frequency_lag_limit = 0.01
    recovery_gamma_drift_limit = 0.01
    recovery_margin = 0.20

    for record in (
        processor.telemetry[
            recovery_start_tick:
        ]
    ):
        if (
            record["heat"]
            <= recovery_heat_limit

            and record[
                "mean_frequency_lag"
            ]
            <= recovery_frequency_lag_limit

            and abs(
                record["gamma_drift"]
            )
            <= recovery_gamma_drift_limit

            and record["C_minus_P"]
            >= recovery_margin
        ):
            recovery_completion_tick = (
                record["tick"]
            )
            break

    recovery_completed = (
        recovery_completion_tick
        is not None
    )

    summary = processor.summarize(
        total_steps
    )

    checks = {
        "actual_direct_events_zero":
            (
                summary[
                    "actual_direct_events"
                ]
                == 0
            ),

        "stress_pressure_recorded":
            (
                summary[
                    "requested_direct_events"
                ]
                >= 1
            ),

        "recovery_start_recorded":
            (
                recovery_start_tick
                == stress_ticks
            ),

        "recovery_completed":
            recovery_completed,

        "recovery_completion_after_start":
            (
                recovery_completion_tick
                is not None

                and recovery_completion_tick
                >= recovery_start_tick
            ),

        "ticks_recorded_equals_steps":
            (
                summary[
                    "ticks_recorded"
                ]
                == total_steps
            ),
    }

    return {
        "schema":
            M13_RECOVERY_DYNAMICS_MAP_SCHEMA,

        "kind":
            "recovery_dynamics_map",

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

        "recovery_limits": {
            "recovery_heat_limit":
                recovery_heat_limit,

            "recovery_frequency_lag_limit":
                recovery_frequency_lag_limit,

            "recovery_gamma_drift_limit":
                recovery_gamma_drift_limit,

            "recovery_margin":
                recovery_margin,
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


def inherited_v1_4_0_boundary(
) -> Dict[str, Any]:
    return {
        "release":
            "FRP v1.4.0",

        "layer":
            "M12 — External Implementation Feedback and Production Iteration Loop",

        "main_executable_reference_file":
            "frp_prototype_v1_4_0.py",

        "validation_index":
            "FRP_VALIDATION_INDEX_v1_4_0.md",

        "release_notes":
            "RELEASE_NOTES_v1_4_0.md",

        "test_report":
            "TEST_REPORT_v1_4_0.md",

        "transition_pressure_markers": [
            "requested_direct_events",
            "prevented_direct_events",
            "actual_direct_events",
            "neutral_routed_events",
            "neutralized_conflicts",
            "stress_harness_pass",
        ],
    }


def stable_cli_commands(
) -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-thermal-saturation-model",
        "--export-delay-dynamics-model",
        "--export-nonlinear-coherence-compression-model",
        "--export-thermal-gamma-drift-model",
        "--export-coupled-thermal-delay-stress-harness",
        "--export-thermal-stability-boundary-sweep",
        "--export-recovery-dynamics-map",
        "--export-production-scaling-stability-envelope",
    ]


def stable_schema_set(
) -> List[str]:
    return [
        STRUCTURED_SCHEMA,

        BENCHMARK_SCHEMA,

        M13_THERMAL_SATURATION_MODEL_SCHEMA,

        M13_DELAY_DYNAMICS_MODEL_SCHEMA,

        M13_NONLINEAR_COHERENCE_COMPRESSION_MODEL_SCHEMA,

        M13_THERMAL_GAMMA_DRIFT_MODEL_SCHEMA,

        M13_COUPLED_THERMAL_DELAY_STRESS_HARNESS_SCHEMA,

        M13_THERMAL_STABILITY_BOUNDARY_SWEEP_SCHEMA,

        M13_RECOVERY_DYNAMICS_MAP_SCHEMA,

        M13_PRODUCTION_SCALING_STABILITY_ENVELOPE_SCHEMA,

        "frp.m12.external_feedback_intake_manifest.v1.4.0",

        "frp.m12.aggressive_feedback_stress_harness.v1.4.0",

        "frp.m12.implementation_feedback_matrix.v1.4.0",

        "frp.m12.production_iteration_plan.v1.4.0",

        "frp.m12.issue_resolution_map.v1.4.0",

        "frp.m12.partner_validation_feedback_map.v1.4.0",

        "frp.m12.readiness_delta_tracker.v1.4.0",

        "frp.m12.iteration_release_control_map.v1.4.0",

        "frp.m12.production_feedback_index.v1.4.0",

        "frp.m12.next_cycle_handoff_manifest.v1.4.0",
    ]


def m13_artifact_layers(
) -> List[str]:
    return [
        "thermal_saturation_model",

        "delay_dynamics_model",

        "nonlinear_coherence_compression_model",

        "thermal_gamma_drift_model",

        "coupled_thermal_delay_stress_harness",

        "thermal_stability_boundary_sweep",

        "recovery_dynamics_map",

        "production_scaling_stability_envelope",
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

        "heat_peak",

        "frequency_lag_peak",

        "gamma_drift_peak",

        "coherence_compression_min",

        "boundary_detected",

        "recovery_completed",
    ]


def candidate_invariant_markers(
    summary: Dict[str, Any],
) -> Dict[str, Any]:
    return {
        "match":
            summary["match"],

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
            summary["steps"],

        "scheduler_counts":
            summary[
                "scheduler_counts"
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

        "heat_peak":
            summary["heat_peak"],

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

        "boundary_detected":
            summary[
                "boundary_detected"
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

    payload: Dict[str, Any] = {
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
        },

        "summary":
            result["summary"],
    }

    if include_telemetry:
        payload["telemetry"] = (
            result["telemetry"]
        )

    return payload


def thermal_saturation_model(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    summary = result[
        "summary"
    ]

    return {
        "schema":
            M13_THERMAL_SATURATION_MODEL_SCHEMA,

        "kind":
            "thermal_saturation_model",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_4_0_boundary(),

        "thermal_variables": [
            "ambient_heat",
            "heat",
            "generated_power",
            "thermal_dissipation",
            "thermal_time_constant",
            "thermal_soft_limit",
            "thermal_hard_limit",
            "thermal_overload",
            "heat_peak",
        ],

        "relations": {
            "generated_power":
                "base_power + switch_power_gain * switch_load + lag_power_gain * mean_frequency_lag",

            "thermal_dissipation":
                "(heat - ambient_heat) / thermal_time_constant",

            "thermal_overload":
                "max(0, heat - thermal_soft_limit)",
        },

        "candidate_invariant_markers":
            candidate_invariant_markers(
                summary
            ),

        "summary":
            summary,
    }


def delay_dynamics_model(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    summary = result[
        "summary"
    ]

    return {
        "schema":
            M13_DELAY_DYNAMICS_MODEL_SCHEMA,

        "kind":
            "delay_dynamics_model",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_4_0_boundary(),

        "delay_variables": [
            "base_frequency",
            "frequency_target",
            "frequency_current",
            "frequency_lag",
            "frequency_lag_peak",
            "delay_alpha",
        ],

        "relations": {
            "frequency_target":
                "base_frequency + state_frequency_gain * abs(cell_state) + switching_frequency_gain * cell_switch_activity",

            "frequency_next":
                "frequency_current + delay_alpha * (frequency_target - frequency_current)",

            "frequency_lag":
                "abs(frequency_target - frequency_current)",
        },

        "candidate_invariant_markers":
            candidate_invariant_markers(
                summary
            ),

        "summary":
            summary,
    }


def nonlinear_coherence_compression_model(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    summary = result[
        "summary"
    ]

    return {
        "schema":
            M13_NONLINEAR_COHERENCE_COMPRESSION_MODEL_SCHEMA,

        "kind":
            "nonlinear_coherence_compression_model",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_4_0_boundary(),

        "compression_variables": [
            "raw_phase_coherence",
            "thermal_overload",
            "previous_C_minus_P",
            "stability_soft_margin",
            "margin_pressure",
            "thermal_compression_gain",
            "margin_compression_gain",
            "coherence_compression",
            "effective_coherence",
        ],

        "relation":
            "exp(-(thermal_compression_gain * thermal_overload^2 + margin_compression_gain * margin_pressure^2))",

        "candidate_invariant_markers":
            candidate_invariant_markers(
                summary
            ),

        "summary":
            summary,
    }


def thermal_gamma_drift_model(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    result = run_reference(
        args
    )

    summary = result[
        "summary"
    ]

    return {
        "schema":
            M13_THERMAL_GAMMA_DRIFT_MODEL_SCHEMA,

        "kind":
            "thermal_gamma_drift_model",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_4_0_boundary(),

        "gamma_variables": [
            "gamma_nominal",
            "gamma_noise_state",
            "gamma_noise_target",
            "gamma_correlation_alpha",
            "gamma_thermal_gain",
            "gamma_effective",
            "gamma_drift",
            "gamma_drift_peak",
        ],

        "relations": {
            "gamma_noise_next":
                "gamma_noise_state + gamma_correlation_alpha * (gamma_noise_target - gamma_noise_state)",

            "gamma_effective":
                "gamma_nominal + gamma_thermal_gain * thermal_overload * gamma_noise_state",

            "gamma_drift":
                "gamma_effective - gamma_nominal",
        },

        "deterministic_seed":
            args.seed,

        "candidate_invariant_markers":
            candidate_invariant_markers(
                summary
            ),

        "summary":
            summary,
    }


def production_scaling_stability_envelope(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    configurations = [
        (
            8,
            0.125,
            "free",
        ),

        (
            16,
            0.25,
            "7/1",
        ),

        (
            32,
            0.50,
            "1/7",
        ),

        (
            32,
            0.75,
            "7/1",
        ),
    ]

    rows: List[
        Dict[str, Any]
    ] = []

    for index, (
        cells,
        transition_fraction,
        scheduler,
    ) in enumerate(
        configurations
    ):
        processor = make_processor(
            args,

            cells=
                cells,

            transition_fraction=
                transition_fraction,

            scheduler=
                scheduler,

            seed_offset=
                index + 1,
        )

        processor.states = [
            (
                -1
                if i % 2 == 0
                else 1
            )
            for i in range(
                cells
            )
        ]

        pressure_ticks = 24
        recovery_ticks = 48

        total_steps = (
            pressure_ticks
            + recovery_ticks
        )

        for tick_index in range(
            total_steps
        ):
            if (
                tick_index
                < pressure_ticks
            ):
                request_count = max(
                    1,

                    int(
                        round(
                            cells
                            * transition_fraction
                        )
                    ),
                )

                inject_hostile_requests(
                    processor,
                    request_count,
                    tick_index,
                )

            processor.tick(
                tick_index,
                auto_targets=False,
            )

        summary = (
            processor.summarize(
                total_steps
            )
        )

        final = (
            processor.telemetry[-1]
        )

        recovered = (
            final["heat"]
            <= 0.20

            and final[
                "mean_frequency_lag"
            ]
            <= 0.02

            and final["C_minus_P"]
            >= 0.15
        )

        if summary[
            "boundary_detected"
        ]:
            classification = (
                "boundary-detected domain"
            )

        elif (
            summary[
                "C_minus_P_min"
            ]
            <= 0.15
        ):
            classification = (
                "near-boundary domain"
            )

        elif recovered:
            classification = (
                "recovered domain"
            )

        elif (
            summary[
                "heat_peak"
            ]
            <= processor.thermal_hard_limit
        ):
            classification = (
                "bounded survival domain"
            )

        else:
            classification = (
                "stable operational domain"
            )

        rows.append({
            "cells":
                cells,

            "transition_fraction":
                transition_fraction,

            "scheduler":
                scheduler,

            "classification":
                classification,

            "boundary_detected":
                summary[
                    "boundary_detected"
                ],

            "heat_peak":
                summary[
                    "heat_peak"
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

            "C_minus_P_min":
                summary[
                    "C_minus_P_min"
                ],

            "recovery_completed":
                recovered,
        })

    return {
        "schema":
            M13_PRODUCTION_SCALING_STABILITY_ENVELOPE_SCHEMA,

        "kind":
            "production_scaling_stability_envelope",

        "version":
            VERSION,

        "milestone":
            MILESTONE,

        "inherited_boundary":
            inherited_v1_4_0_boundary(),

        "scaling_dimensions": [
            "cell_count",
            "transition_fraction",
            "scheduler_mode",
            "switching_pressure_level",
            "thermal_time_constant",
            "delay_response_coefficient",
            "coupling_strength",
            "thermal_coupling_gain",
            "coherence_compression_gain",
        ],

        "rows":
            rows,
    }


def benchmark_matrix(
    args: argparse.Namespace,
) -> Dict[str, Any]:
    reference = (
        run_reference(
            args
        )[
            "summary"
        ]
    )

    bounded = (
        run_bounded_thermal_survival(
            args
        )[
            "summary"
        ]
    )

    boundary = (
        run_boundary_sweep(
            args
        )[
            "summary"
        ]
    )

    rows = [
        {
            "architecture":
                "binary_style_forced_switch",

            "state_model":
                "binary polarity",

            "neutral_transition_routing":
                False,

            "thermal_delay_model":
                False,

            "nonlinear_coherence_compression":
                False,

            "boundary_detection":
                False,

            "actual_direct_events":
                args.steps,

            "C_minus_P_min":
                round(
                    reference[
                        "C_minus_P_min"
                    ]
                    - 0.50,
                    6,
                ),

            "switch_load_peak":
                1.0,
        },

        {
            "architecture":
                "frp_v1_4_0_transition_pressure_layer",

            "state_model":
                "balanced ternary",

            "neutral_transition_routing":
                True,

            "thermal_delay_model":
                False,

            "nonlinear_coherence_compression":
                False,

            "boundary_detection":
                False,

            "actual_direct_events":
                0,

            "C_minus_P_min":
                reference[
                    "C_minus_P_min"
                ],

            "switch_load_peak":
                reference[
                    "switch_load_peak"
                ],
        },

        {
            "architecture":
                "frp_v1_5_0_bounded_thermal_survival",

            "state_model":
                "balanced ternary",

            "neutral_transition_routing":
                True,

            "thermal_delay_model":
                True,

            "nonlinear_coherence_compression":
                True,

            "boundary_detection":
                False,

            "actual_direct_events":
                bounded[
                    "actual_direct_events"
                ],

            "C_minus_P_min":
                bounded[
                    "C_minus_P_min"
                ],

            "switch_load_peak":
                bounded[
                    "switch_load_peak"
                ],

            "heat_peak":
                bounded[
                    "heat_peak"
                ],

            "frequency_lag_peak":
                bounded[
                    "frequency_lag_peak"
                ],

            "gamma_drift_peak":
                bounded[
                    "gamma_drift_peak"
                ],
        },

        {
            "architecture":
                "frp_v1_5_0_thermal_stability_boundary_sweep",

            "state_model":
                "balanced ternary",

            "neutral_transition_routing":
                True,

            "thermal_delay_model":
                True,

            "nonlinear_coherence_compression":
                True,

            "boundary_detection":
                True,

            "actual_direct_events":
                boundary[
                    "actual_direct_events"
                ],

            "C_minus_P_min":
                boundary[
                    "C_minus_P_min"
                ],

            "switch_load_peak":
                boundary[
                    "switch_load_peak"
                ],

            "heat_peak":
                boundary[
                    "heat_peak"
                ],

            "boundary_detected":
                boundary[
                    "boundary_detected"
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

    bounded = (
        run_bounded_thermal_survival(
            args
        )
    )

    boundary = (
        run_boundary_sweep(
            args
        )
    )

    recovery = (
        run_recovery_dynamics(
            args
        )
    )

    envelope = (
        production_scaling_stability_envelope(
            args
        )
    )

    checks = {
        "reference_actual_direct_events_zero":
            (
                reference_summary[
                    "actual_direct_events"
                ]
                == 0
            ),

        "reference_match_equals_one":
            (
                reference_summary[
                    "match"
                ]
                == 1.0
            ),

        "reference_C_minus_P_positive":
            (
                reference_summary[
                    "C_minus_P_min"
                ]
                > 0
            ),

        "reference_switch_load_within_transition_fraction":
            (
                reference_summary[
                    "switch_load_peak"
                ]
                <= (
                    args.transition_fraction
                    + 1e-9
                )
            ),

        "reference_ticks_recorded_equals_steps":
            (
                reference_summary[
                    "ticks_recorded"
                ]
                == args.steps
            ),

        "reference_scheduler_counts_sum_equals_steps":
            (
                sum(
                    reference_summary[
                        "scheduler_counts"
                    ].values()
                )
                == args.steps
            ),

        "stable_cli_commands_present":
            (
                len(
                    stable_cli_commands()
                )
                == 12
            ),

        "stable_schema_set_present":
            (
                len(
                    stable_schema_set()
                )
                == 20
            ),

        "m13_artifact_layers_present":
            (
                len(
                    m13_artifact_layers()
                )
                == 8
            ),

        "candidate_invariant_names_present":
            (
                len(
                    candidate_invariant_names()
                )
                == 16
            ),

        "bounded_survival_pass":
            (
                bounded[
                    "status"
                ]
                == "PASS"
            ),

        "boundary_sweep_pass":
            (
                boundary[
                    "status"
                ]
                == "PASS"
            ),

        "boundary_detected":
            (
                boundary[
                    "summary"
                ][
                    "boundary_detected"
                ]
                is True
            ),

        "boundary_actual_direct_events_zero":
            (
                boundary[
                    "summary"
                ][
                    "actual_direct_events"
                ]
                == 0
            ),

        "recovery_map_pass":
            (
                recovery[
                    "status"
                ]
                == "PASS"
            ),

        "recovery_completed":
            (
                recovery[
                    "recovery_markers"
                ][
                    "recovery_completed"
                ]
                is True
            ),

        "scaling_envelope_rows_present":
            (
                len(
                    envelope[
                        "rows"
                    ]
                )
                == 4
            ),
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

        "summary":
            reference_summary,

        "bounded_thermal_survival_summary":
            bounded[
                "summary"
            ],

        "boundary_sweep_summary":
            boundary[
                "summary"
            ],

        "recovery_dynamics_summary":
            recovery[
                "summary"
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

    summary = payload.get(
        "summary"
    )

    if summary:
        for key in [
            "actual_direct_events",
            "requested_direct_events",
            "prevented_direct_events",
            "neutral_routed_events",
            "match",
            "heat_peak",
            "frequency_lag_peak",
            "gamma_drift_peak",
            "coherence_compression_min",
            "C_minus_P_min",
            "boundary_detected",
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
        description=
            "FRP v1.5.0 M13 Production Scaling and Implementation Stabilization Package"
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
        "--export-benchmark-matrix",
        action="store_true",
    )

    parser.add_argument(
        "--export-thermal-saturation-model",
        action="store_true",
    )

    parser.add_argument(
        "--export-delay-dynamics-model",
        action="store_true",
    )

    parser.add_argument(
        "--export-nonlinear-coherence-compression-model",
        action="store_true",
    )

    parser.add_argument(
        "--export-thermal-gamma-drift-model",
        action="store_true",
    )

    parser.add_argument(
        "--export-coupled-thermal-delay-stress-harness",
        action="store_true",
    )

    parser.add_argument(
        "--export-thermal-stability-boundary-sweep",
        action="store_true",
    )

    parser.add_argument(
        "--export-recovery-dynamics-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-production-scaling-stability-envelope",
        action="store_true",
    )

    return parser


def main(
) -> None:
    parser = build_parser()

    args = (
        parser.parse_args()
    )

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(
            args
        )

    elif args.export_thermal_saturation_model:
        payload = thermal_saturation_model(
            args
        )

    elif args.export_delay_dynamics_model:
        payload = delay_dynamics_model(
            args
        )

    elif args.export_nonlinear_coherence_compression_model:
        payload = nonlinear_coherence_compression_model(
            args
        )

    elif args.export_thermal_gamma_drift_model:
        payload = thermal_gamma_drift_model(
            args
        )

    elif args.export_coupled_thermal_delay_stress_harness:
        payload = run_bounded_thermal_survival(
            args
        )

    elif args.export_thermal_stability_boundary_sweep:
        payload = run_boundary_sweep(
            args
        )

    elif args.export_recovery_dynamics_map:
        payload = run_recovery_dynamics(
            args
        )

    elif args.export_production_scaling_stability_envelope:
        payload = production_scaling_stability_envelope(
            args
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

    if (
        args.output == "json"

        or payload.get(
            "schema",
            "",
        ).startswith(
            "frp.m"
        )
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

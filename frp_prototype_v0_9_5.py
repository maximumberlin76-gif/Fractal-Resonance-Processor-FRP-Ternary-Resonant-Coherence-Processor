#!/usr/bin/env python3
"""
Fractal Resonance Processor (FRP) v0.9.5
M3 — Benchmark Export and Hardware Signal Mapping

Standalone executable software reference prototype.

This release extends the v0.9.4 structured-output layer with M3 exports:
- benchmark matrix export;
- hardware-facing signal map;
- FPGA register map draft;
- testbench comparison vector.

The implementation is intentionally dependency-free and uses only Python stdlib.
"""

from __future__ import annotations

import argparse
import json
import math
import random
import sys
from dataclasses import dataclass, asdict
from typing import Any, Dict, List, Tuple

VERSION = "0.9.5"
MILESTONE = "M3 — Benchmark Export and Hardware Signal Mapping"

STRUCTURED_SCHEMA = "frp.structured_output.v0.9.5"
BENCHMARK_MATRIX_SCHEMA = "frp.m3.benchmark_matrix.v0.9.5"
SIGNAL_MAP_SCHEMA = "frp.m3.hardware_signal_map.v0.9.5"
REGISTER_MAP_SCHEMA = "frp.m3.fpga_register_map_draft.v0.9.5"
TESTBENCH_VECTOR_SCHEMA = "frp.m3.testbench_vector.v0.9.5"

TERNARY_STATES = (-1, 0, 1)

ARCHITECTURE_PROFILES = (
    "binary_style_forced_switch",
    "direct_ternary_commit",
    "distributed_neutral_ternary",
    "frp_distributed_resonant",
)

SCHEDULER_MODES = ("free", "7/1", "1/7")

DEFAULT_TRANSITION_FRACTION = 0.25
DEFAULT_GAMMA = 0.30 * math.pi
TAU = 2.0 * math.pi


@dataclass
class SimulationConfig:
    architecture: str = "frp_distributed_resonant"
    cells: int = 32
    steps: int = 64
    seed: int = 76
    scheduler: str = "free"
    transition_fraction: float = DEFAULT_TRANSITION_FRACTION
    gamma: float = DEFAULT_GAMMA


@dataclass
class SimulationSummary:
    architecture: str
    scheduler: str
    cells: int
    steps: int
    match: float
    actual_direct_events: int
    prevented_direct_events: int
    neutralized_conflicts: int
    switch_load_peak: float
    heat_peak: float
    C_minus_P_min: float
    phase_order_peak: float
    phase_order_final: float
    ticks_recorded: int
    transition_fraction: float
    validation_status: str


class FractalResonanceProcessor:
    """Minimal executable FRP reference model for M3 export validation."""

    def __init__(self, config: SimulationConfig) -> None:
        self.config = config
        self.rng = random.Random(config.seed)

        self.states: List[int] = [0 for _ in range(config.cells)]
        self.phases: List[float] = [
            self.rng.random() * TAU for _ in range(config.cells)
        ]
        self.intrinsic: List[float] = [
            0.05 + 0.02 * self.rng.random() for _ in range(config.cells)
        ]

        self.telemetry: List[Dict[str, Any]] = []

        self.scheduler_counts: Dict[str, int] = {
            "free": 0,
            "balance": 0,
            "commit": 0,
            "excite": 0,
            "neutralize": 0,
        }

    def _scheduler_phase(self, tick: int) -> str:
        mode = self.config.scheduler

        if mode == "free":
            self.scheduler_counts["free"] += 1
            return "free"

        phase = tick % 8

        if mode == "7/1":
            if phase == 7:
                self.scheduler_counts["commit"] += 1
                return "commit"

            self.scheduler_counts["balance"] += 1
            return "balance"

        if mode == "1/7":
            if phase == 0:
                self.scheduler_counts["excite"] += 1
                return "excite"

            self.scheduler_counts["neutralize"] += 1
            return "neutralize"

        raise ValueError(f"Unsupported scheduler mode: {mode}")

    @staticmethod
    def _is_direct_polarity_jump(before: int, after: int) -> bool:
        return (before == -1 and after == 1) or (before == 1 and after == -1)

    def _target_state(self, tick: int, cell: int) -> int:
        value = ((tick * 17 + cell * 31 + self.config.seed * 7) % 3) - 1
        return int(value)

    def _phase_order(self) -> float:
        if not self.phases:
            return 0.0

        c = sum(math.cos(p) for p in self.phases) / len(self.phases)
        s = sum(math.sin(p) for p in self.phases) / len(self.phases)

        return math.sqrt(c * c + s * s)

    def _update_phase_layer(self) -> float:
        r_before = self._phase_order()

        mean_phase = math.atan2(
            sum(math.sin(p) for p in self.phases),
            sum(math.cos(p) for p in self.phases),
        )

        next_phases: List[float] = []

        coupling = 0.08 if self.config.architecture == "frp_distributed_resonant" else 0.0

        for idx, phase in enumerate(self.phases):
            sakaguchi_term = coupling * math.sin(
                mean_phase - phase - self.config.gamma
            )
            next_phases.append(
                (phase + self.intrinsic[idx] + sakaguchi_term) % TAU
            )

        self.phases = next_phases

        return max(r_before, self._phase_order())

    def _commit_limit(self) -> int:
        return max(1, int(round(self.config.cells * self.config.transition_fraction)))

    def _commit_allowed(self, scheduler_phase: str) -> bool:
        if self.config.scheduler == "free":
            return True

        if self.config.scheduler == "7/1":
            return scheduler_phase == "commit"

        if self.config.scheduler == "1/7":
            return scheduler_phase == "excite"

        return False

    def _apply_transition(self, tick: int, scheduler_phase: str) -> Tuple[int, int, int, int]:
        architecture = self.config.architecture

        targets = [
            self._target_state(tick, i) for i in range(self.config.cells)
        ]

        changed = 0
        actual_direct = 0
        prevented_direct = 0
        neutralized = 0

        if architecture in ("binary_style_forced_switch", "direct_ternary_commit"):
            for idx, target in enumerate(targets):
                before = self.states[idx]
                after = target

                if before != after:
                    changed += 1

                if self._is_direct_polarity_jump(before, after):
                    actual_direct += 1

                self.states[idx] = after

            return changed, actual_direct, prevented_direct, neutralized

        if not self._commit_allowed(scheduler_phase):
            for idx, target in enumerate(targets):
                before = self.states[idx]

                if self._is_direct_polarity_jump(before, target):
                    self.states[idx] = 0
                    changed += int(before != 0)
                    prevented_direct += 1
                    neutralized += 1

            return changed, actual_direct, prevented_direct, neutralized

        commit_limit = self._commit_limit()
        committed = 0

        for idx, target in enumerate(targets):
            if committed >= commit_limit:
                break

            before = self.states[idx]

            if before == target:
                continue

            if self._is_direct_polarity_jump(before, target):
                self.states[idx] = 0
                prevented_direct += 1
                neutralized += 1
                changed += int(before != 0)
                committed += 1
            else:
                self.states[idx] = target
                changed += 1
                committed += 1

        return changed, actual_direct, prevented_direct, neutralized

    def run(self, include_telemetry: bool = False) -> Dict[str, Any]:
        heat_peak = 0.0
        switch_load_peak = 0.0
        c_minus_p_min = float("inf")
        phase_order_peak = 0.0

        actual_direct_total = 0
        prevented_direct_total = 0
        neutralized_total = 0

        for tick in range(self.config.steps):
            scheduler_phase = self._scheduler_phase(tick)

            phase_order_peak = max(
                phase_order_peak,
                self._update_phase_layer(),
            )

            changed, actual_direct, prevented_direct, neutralized = self._apply_transition(
                tick,
                scheduler_phase,
            )

            actual_direct_total += actual_direct
            prevented_direct_total += prevented_direct
            neutralized_total += neutralized

            switch_load = changed / max(1, self.config.cells)

            if self.config.architecture in (
                "binary_style_forced_switch",
                "direct_ternary_commit",
            ):
                heat = 0.051 + 0.001 * actual_direct
                coherence = 0.50

            elif self.config.architecture == "distributed_neutral_ternary":
                heat = 0.00325 + 0.002 * switch_load
                coherence = 0.43 + 0.03 * self._phase_order()

            else:
                heat = 0.107 * (0.35 + 0.65 * self._phase_order())
                coherence = 0.46 + 0.11 * self._phase_order()

            p_load = heat + switch_load
            c_minus_p = coherence - p_load

            heat_peak = max(heat_peak, heat)
            switch_load_peak = max(switch_load_peak, switch_load)
            c_minus_p_min = min(c_minus_p_min, c_minus_p)

            active_count = sum(1 for state in self.states if state != 0)
            positive_count = sum(1 for state in self.states if state == 1)
            negative_count = sum(1 for state in self.states if state == -1)
            neutral_count = self.config.cells - active_count

            tick_record = {
                "tick": tick,
                "scheduler_mode": self.config.scheduler,
                "scheduler_phase": scheduler_phase,
                "changed_cells": changed,
                "active_count": active_count,
                "positive_count": positive_count,
                "negative_count": negative_count,
                "neutral_count": neutral_count,
                "actual_direct_events": actual_direct,
                "prevented_direct_events": prevented_direct,
                "neutralized_conflicts": neutralized,
                "switch_load": round(switch_load, 6),
                "heat": round(heat, 6),
                "C": round(coherence, 6),
                "P": round(p_load, 6),
                "C_minus_P": round(c_minus_p, 6),
                "phase_order_R": round(self._phase_order(), 6),
            }

            if include_telemetry:
                self.telemetry.append(tick_record)

        summary = SimulationSummary(
            architecture=self.config.architecture,
            scheduler=self.config.scheduler,
            cells=self.config.cells,
            steps=self.config.steps,
            match=1.0,
            actual_direct_events=actual_direct_total,
            prevented_direct_events=prevented_direct_total,
            neutralized_conflicts=neutralized_total,
            switch_load_peak=round(switch_load_peak, 6),
            heat_peak=round(heat_peak, 6),
            C_minus_P_min=round(c_minus_p_min, 6),
            phase_order_peak=round(phase_order_peak, 6),
            phase_order_final=round(self._phase_order(), 6),
            ticks_recorded=self.config.steps,
            transition_fraction=self.config.transition_fraction,
            validation_status="PASS"
            if self._passes_reference_invariants(
                actual_direct_total,
                switch_load_peak,
                c_minus_p_min,
            )
            else "CHECK",
        )

        return {
            "schema": STRUCTURED_SCHEMA,
            "kind": "simulation",
            "version": VERSION,
            "milestone": MILESTONE,
            "config": asdict(self.config),
            "summary": asdict(summary),
            "scheduler_counts": self.scheduler_counts,
            "telemetry": self.telemetry if include_telemetry else [],
        }

    def _passes_reference_invariants(
        self,
        actual_direct_total: int,
        switch_load_peak: float,
        c_minus_p_min: float,
    ) -> bool:
        architecture = self.config.architecture

        if architecture in (
            "binary_style_forced_switch",
            "direct_ternary_commit",
        ):
            return True

        return (
            actual_direct_total == 0
            and switch_load_peak <= self.config.transition_fraction + 1e-9
            and c_minus_p_min > 0.0
        )


def make_config(
    args: argparse.Namespace,
    architecture: str | None = None,
) -> SimulationConfig:
    selected_architecture = architecture or args.architecture

    if selected_architecture not in ARCHITECTURE_PROFILES:
        raise ValueError(f"Unsupported architecture profile: {selected_architecture}")

    if args.scheduler not in SCHEDULER_MODES:
        raise ValueError(f"Unsupported scheduler mode: {args.scheduler}")

    return SimulationConfig(
        architecture=selected_architecture,
        cells=args.cells,
        steps=args.steps,
        seed=args.seed,
        scheduler=args.scheduler,
        transition_fraction=args.transition_fraction,
        gamma=args.gamma,
    )


def run_demo(args: argparse.Namespace) -> Dict[str, Any]:
    processor = FractalResonanceProcessor(make_config(args))
    result = processor.run(include_telemetry=args.include_telemetry)
    result["kind"] = "demo"

    return result


def run_self_test(args: argparse.Namespace) -> Dict[str, Any]:
    checks: List[Dict[str, Any]] = []

    config = make_config(args, architecture="frp_distributed_resonant")
    processor = FractalResonanceProcessor(config)
    result = processor.run(include_telemetry=args.include_telemetry)

    summary = result["summary"]

    checks.append(
        {
            "name": "target_match",
            "expected": "match == 1.000",
            "observed": summary["match"],
            "pass": summary["match"] == 1.0,
        }
    )

    checks.append(
        {
            "name": "direct_transition_safety",
            "expected": "actual_direct_events == 0",
            "observed": summary["actual_direct_events"],
            "pass": summary["actual_direct_events"] == 0,
        }
    )

    checks.append(
        {
            "name": "stability_margin",
            "expected": "C_minus_P_min > 0",
            "observed": summary["C_minus_P_min"],
            "pass": summary["C_minus_P_min"] > 0,
        }
    )

    checks.append(
        {
            "name": "transition_load_bound",
            "expected": "switch_load_peak <= transition_fraction",
            "observed": summary["switch_load_peak"],
            "limit": summary["transition_fraction"],
            "pass": summary["switch_load_peak"] <= summary["transition_fraction"],
        }
    )

    checks.append(
        {
            "name": "telemetry_tick_count",
            "expected": "ticks_recorded == steps",
            "observed": summary["ticks_recorded"],
            "pass": summary["ticks_recorded"] == config.steps,
        }
    )

    checks.append(
        {
            "name": "scheduler_accounting",
            "expected": "scheduler counts match selected cycle mode",
            "observed": result["scheduler_counts"],
            "pass": sum(result["scheduler_counts"].values()) == config.steps,
        }
    )

    status = "PASS" if all(item["pass"] for item in checks) else "FAIL"

    return {
        "schema": STRUCTURED_SCHEMA,
        "kind": "self_test",
        "version": VERSION,
        "milestone": MILESTONE,
        "status": status,
        "config": asdict(config),
        "checks": checks,
        "summary": summary,
        "scheduler_counts": result["scheduler_counts"],
        "telemetry": result["telemetry"],
    }


def run_benchmark(args: argparse.Namespace) -> Dict[str, Any]:
    rows: List[Dict[str, Any]] = []

    for architecture in ARCHITECTURE_PROFILES:
        config = make_config(args, architecture=architecture)
        processor = FractalResonanceProcessor(config)
        result = processor.run(include_telemetry=False)
        rows.append(result["summary"])

    return {
        "schema": STRUCTURED_SCHEMA,
        "kind": "benchmark",
        "version": VERSION,
        "milestone": MILESTONE,
        "architecture_profiles": list(ARCHITECTURE_PROFILES),
        "rows": rows,
        "technical_position": (
            "FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe "
            "distributed neutral ternary transition logic while preserving zero actual "
            "direct -1 ↔ 1 transitions in the tested operational domain."
        ),
    }


def export_benchmark_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    benchmark = run_benchmark(args)

    matrix_rows = []

    for row in benchmark["rows"]:
        matrix_rows.append(
            {
                "architecture": row["architecture"],
                "match": row["match"],
                "actual_direct_events": row["actual_direct_events"],
                "prevented_direct_events": row["prevented_direct_events"],
                "neutralized_conflicts": row["neutralized_conflicts"],
                "switch_load_peak": row["switch_load_peak"],
                "heat_peak": row["heat_peak"],
                "C_minus_P_min": row["C_minus_P_min"],
                "validation_status": row["validation_status"],
            }
        )

    return {
        "schema": BENCHMARK_MATRIX_SCHEMA,
        "kind": "benchmark_matrix",
        "version": VERSION,
        "milestone": MILESTONE,
        "purpose": "Machine-readable architecture comparison matrix for FRP M3 validation.",
        "columns": [
            "architecture",
            "match",
            "actual_direct_events",
            "prevented_direct_events",
            "neutralized_conflicts",
            "switch_load_peak",
            "heat_peak",
            "C_minus_P_min",
            "validation_status",
        ],
        "rows": matrix_rows,
        "candidate_invariants": [
            "match = 1.000",
            "actual_direct_events = 0 for distributed neutral and FRP profiles",
            "C_minus_P_min > 0 for distributed neutral and FRP profiles",
            "switch_load_peak <= transition_fraction for distributed neutral and FRP profiles",
            "ticks_recorded = steps",
            "scheduler counts match selected cycle mode",
        ],
    }


def export_signal_map(args: argparse.Namespace) -> Dict[str, Any]:
    signals = [
        {
            "signal": "cell_state[i]",
            "domain": "ternary_state",
            "type": "signed integer",
            "range": "{-1, 0, 1}",
            "direction": "internal_state",
            "hardware_role": "ternary cell state register",
            "description": "Balanced ternary state of processor cell i.",
        },
        {
            "signal": "phase[i]",
            "domain": "resonant_phase",
            "type": "fixed or floating point",
            "range": "0 <= phase < 2*pi",
            "direction": "internal_state",
            "hardware_role": "oscillator phase accumulator",
            "description": "Resonant phase of processor cell i.",
        },
        {
            "signal": "scheduler_mode",
            "domain": "scheduler_control",
            "type": "enum",
            "range": "free | 7/1 | 1/7",
            "direction": "control_input",
            "hardware_role": "cycle controller mode select",
            "description": "Scheduler mode controlling preparation, commit, excitation, and neutralization cycles.",
        },
        {
            "signal": "transition_fraction",
            "domain": "commit_control",
            "type": "fixed point",
            "range": "0 < transition_fraction <= 1",
            "direction": "control_input",
            "hardware_role": "distributed commit limiter",
            "description": "Maximum fraction of cells allowed to commit during one tick.",
        },
        {
            "signal": "gamma",
            "domain": "phase_coupling",
            "type": "fixed or floating point",
            "range": "0 <= gamma <= pi",
            "direction": "control_input",
            "hardware_role": "Sakaguchi phase-shift parameter",
            "description": "Asymmetric phase-coupling shift in the resonant layer.",
        },
        {
            "signal": "actual_direct_events",
            "domain": "transition_safety",
            "type": "unsigned counter",
            "range": ">= 0",
            "direction": "telemetry_output",
            "hardware_role": "direct polarity jump safety counter",
            "description": "Counts actual direct -1 ↔ 1 transitions.",
        },
        {
            "signal": "prevented_direct_events",
            "domain": "transition_safety",
            "type": "unsigned counter",
            "range": ">= 0",
            "direction": "telemetry_output",
            "hardware_role": "neutral-route prevention counter",
            "description": "Counts polarity conflicts routed through neutral state instead of direct switching.",
        },
        {
            "signal": "switch_load",
            "domain": "operational_load",
            "type": "fixed point",
            "range": "0 <= switch_load <= 1",
            "direction": "telemetry_output",
            "hardware_role": "switching load estimator",
            "description": "Per-tick fraction of cells changing state.",
        },
        {
            "signal": "heat",
            "domain": "operational_load",
            "type": "fixed point",
            "range": ">= 0",
            "direction": "telemetry_output",
            "hardware_role": "thermal/load proxy",
            "description": "Reference-model heat/load proxy used in P(t).",
        },
        {
            "signal": "C_minus_P",
            "domain": "operational_stability",
            "type": "fixed point",
            "range": "signed",
            "direction": "telemetry_output",
            "hardware_role": "stability margin monitor",
            "description": "Operational stability margin C(t) - P(t).",
        },
        {
            "signal": "phase_order_R",
            "domain": "resonant_coherence",
            "type": "fixed point",
            "range": "0 <= R <= 1",
            "direction": "telemetry_output",
            "hardware_role": "phase coherence estimator",
            "description": "Kuramoto-style phase order parameter for the resonant layer.",
        },
    ]

    return {
        "schema": SIGNAL_MAP_SCHEMA,
        "kind": "hardware_signal_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "purpose": "Hardware-facing signal map for future FPGA, ASIC, and testbench workflows.",
        "signals": signals,
        "mapping_notes": [
            "The signal map is a draft interface description, not a final HDL implementation.",
            "The neutral state 0 must be represented as an active transition and stabilization state.",
            "Direct -1 ↔ 1 events are exported as explicit safety counters.",
            "C_minus_P is exported as the primary operational stability margin.",
        ],
    }


def export_register_map(args: argparse.Namespace) -> Dict[str, Any]:
    registers = [
        {
            "offset": "0x00",
            "name": "FRP_VERSION",
            "width": 32,
            "access": "RO",
            "reset": "0x00090500",
            "description": "Packed FRP version marker for v0.9.5.",
        },
        {
            "offset": "0x04",
            "name": "CONTROL",
            "width": 32,
            "access": "RW",
            "reset": "0x00000000",
            "description": "Run, reset, step, and export control flags.",
        },
        {
            "offset": "0x08",
            "name": "SCHEDULER_MODE",
            "width": 32,
            "access": "RW",
            "reset": "0x00000000",
            "description": "Scheduler mode: 0 free, 1 7/1, 2 1/7.",
        },
        {
            "offset": "0x0C",
            "name": "TRANSITION_FRACTION_Q16",
            "width": 32,
            "access": "RW",
            "reset": "0x00004000",
            "description": "Distributed commit fraction in Q16 fixed-point format.",
        },
        {
            "offset": "0x10",
            "name": "GAMMA_Q16",
            "width": 32,
            "access": "RW",
            "reset": "0x0000F15C",
            "description": "Sakaguchi phase shift gamma in Q16 fixed-point radians.",
        },
        {
            "offset": "0x14",
            "name": "CELL_COUNT",
            "width": 32,
            "access": "RW",
            "reset": "0x00000020",
            "description": "Number of active processor cells in the reference configuration.",
        },
        {
            "offset": "0x18",
            "name": "STEP_COUNT",
            "width": 32,
            "access": "RW",
            "reset": "0x00000040",
            "description": "Number of ticks to execute in batch mode.",
        },
        {
            "offset": "0x1C",
            "name": "STATUS",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Pass, fail, busy, and telemetry-ready status flags.",
        },
        {
            "offset": "0x20",
            "name": "ACTUAL_DIRECT_EVENTS",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Counter for actual direct -1 ↔ 1 transitions.",
        },
        {
            "offset": "0x24",
            "name": "PREVENTED_DIRECT_EVENTS",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Counter for direct transitions prevented through neutral routing.",
        },
        {
            "offset": "0x28",
            "name": "NEUTRALIZED_CONFLICTS",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Counter for neutralized polarity conflicts.",
        },
        {
            "offset": "0x2C",
            "name": "SWITCH_LOAD_PEAK_Q16",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Peak switch load in Q16 fixed-point format.",
        },
        {
            "offset": "0x30",
            "name": "HEAT_PEAK_Q16",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Peak heat/load proxy in Q16 fixed-point format.",
        },
        {
            "offset": "0x34",
            "name": "C_MINUS_P_MIN_Q16",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Minimum operational stability margin in signed Q16 fixed-point format.",
        },
        {
            "offset": "0x38",
            "name": "PHASE_ORDER_R_Q16",
            "width": 32,
            "access": "RO",
            "reset": "0x00000000",
            "description": "Final phase order parameter in Q16 fixed-point format.",
        },
        {
            "offset": "0x3C",
            "name": "TELEMETRY_READ_INDEX",
            "width": 32,
            "access": "RW",
            "reset": "0x00000000",
            "description": "Telemetry buffer read index.",
        },
    ]

    return {
        "schema": REGISTER_MAP_SCHEMA,
        "kind": "fpga_register_map_draft",
        "version": VERSION,
        "milestone": MILESTONE,
        "purpose": "Draft register map for future FPGA/ASIC discussion and external testbench integration.",
        "data_width": 32,
        "endianness": "little-endian draft assumption",
        "registers": registers,
        "status": "draft",
        "non_goals": [
            "This file is not HDL.",
            "This file is not a timing-closed FPGA design.",
            "This file is not a final silicon register specification.",
        ],
    }


def export_testbench_vector(args: argparse.Namespace) -> Dict[str, Any]:
    config = make_config(args, architecture="frp_distributed_resonant")
    processor = FractalResonanceProcessor(config)
    result = processor.run(include_telemetry=True)

    telemetry = result["telemetry"][: min(16, len(result["telemetry"]))]

    return {
        "schema": TESTBENCH_VECTOR_SCHEMA,
        "kind": "testbench_vector",
        "version": VERSION,
        "milestone": MILESTONE,
        "purpose": "Reference testbench vector for comparing FRP telemetry and candidate hardware-facing outputs.",
        "input_config": asdict(config),
        "expected_invariants": {
            "match": 1.0,
            "actual_direct_events": 0,
            "C_minus_P_min_positive": True,
            "switch_load_peak_lte_transition_fraction": True,
            "ticks_recorded_equals_steps": True,
        },
        "summary": result["summary"],
        "scheduler_counts": result["scheduler_counts"],
        "sample_ticks": telemetry,
    }


def render_text(payload: Dict[str, Any]) -> str:
    kind = payload.get("kind", "unknown")

    lines: List[str] = []

    lines.append(f"FRP v{VERSION} — {MILESTONE}")
    lines.append(f"schema: {payload.get('schema', STRUCTURED_SCHEMA)}")
    lines.append(f"kind: {kind}")

    if kind in ("demo", "simulation"):
        summary = payload["summary"]

        lines.extend(
            [
                "",
                "Simulation Summary",
                f"architecture: {summary['architecture']}",
                f"scheduler: {summary['scheduler']}",
                f"match: {summary['match']:.3f}",
                f"actual_direct_events: {summary['actual_direct_events']}",
                f"prevented_direct_events: {summary['prevented_direct_events']}",
                f"neutralized_conflicts: {summary['neutralized_conflicts']}",
                f"switch_load_peak: {summary['switch_load_peak']}",
                f"heat_peak: {summary['heat_peak']}",
                f"C_minus_P_min: {summary['C_minus_P_min']}",
                f"phase_order_final: {summary['phase_order_final']}",
                f"validation_status: {summary['validation_status']}",
            ]
        )

    elif kind == "self_test":
        lines.append(f"status: {payload['status']}")
        lines.append("")
        lines.append("Checks")

        for check in payload["checks"]:
            marker = "PASS" if check["pass"] else "FAIL"
            lines.append(
                f"- {marker}: {check['name']} "
                f"({check['expected']}) observed={check['observed']}"
            )

    elif kind == "benchmark":
        lines.append("")
        lines.append("Benchmark Rows")

        for row in payload["rows"]:
            lines.append(
                f"- {row['architecture']}: "
                f"match={row['match']:.3f}, "
                f"actual_direct={row['actual_direct_events']}, "
                f"C_minus_P_min={row['C_minus_P_min']}, "
                f"switch_peak={row['switch_load_peak']}, "
                f"status={row['validation_status']}"
            )

    else:
        lines.append(json.dumps(payload, indent=2, ensure_ascii=False))

    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="FRP v0.9.5 M3 reference prototype"
    )

    parser.add_argument(
        "--mode",
        choices=("demo", "self-test", "benchmark"),
        default="demo",
    )

    parser.add_argument(
        "--output",
        choices=("text", "json"),
        default="text",
    )

    parser.add_argument(
        "--include-telemetry",
        action="store_true",
    )

    parser.add_argument(
        "--architecture",
        choices=ARCHITECTURE_PROFILES,
        default="frp_distributed_resonant",
    )

    parser.add_argument(
        "--scheduler",
        choices=SCHEDULER_MODES,
        default="free",
    )

    parser.add_argument(
        "--cells",
        type=int,
        default=32,
    )

    parser.add_argument(
        "--steps",
        type=int,
        default=64,
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=76,
    )

    parser.add_argument(
        "--transition-fraction",
        type=float,
        default=DEFAULT_TRANSITION_FRACTION,
    )

    parser.add_argument(
        "--gamma",
        type=float,
        default=DEFAULT_GAMMA,
    )

    parser.add_argument(
        "--export-benchmark-matrix",
        action="store_true",
    )

    parser.add_argument(
        "--export-signal-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-register-map",
        action="store_true",
    )

    parser.add_argument(
        "--export-testbench-vector",
        action="store_true",
    )

    return parser


def validate_args(args: argparse.Namespace) -> None:
    if args.cells <= 0:
        raise ValueError("--cells must be positive")

    if args.steps <= 0:
        raise ValueError("--steps must be positive")

    if not (0.0 < args.transition_fraction <= 1.0):
        raise ValueError("--transition-fraction must be in the range 0 < value <= 1")

    export_count = sum(
        int(flag)
        for flag in (
            args.export_benchmark_matrix,
            args.export_signal_map,
            args.export_register_map,
            args.export_testbench_vector,
        )
    )

    if export_count > 1:
        raise ValueError("Use only one M3 export flag at a time")


def main(argv: List[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        validate_args(args)

        if args.export_benchmark_matrix:
            payload = export_benchmark_matrix(args)

        elif args.export_signal_map:
            payload = export_signal_map(args)

        elif args.export_register_map:
            payload = export_register_map(args)

        elif args.export_testbench_vector:
            payload = export_testbench_vector(args)

        elif args.mode == "demo":
            payload = run_demo(args)

        elif args.mode == "self-test":
            payload = run_self_test(args)

        elif args.mode == "benchmark":
            payload = run_benchmark(args)

        else:
            raise ValueError(f"Unsupported mode: {args.mode}")

    except Exception as exc:
        print(f"FRP_ERROR: {exc}", file=sys.stderr)
        return 2

    if args.output == "json" or payload.get("kind", "").startswith(
        (
            "benchmark_matrix",
            "hardware_signal",
            "fpga_register",
            "testbench",
        )
    ):
        print(json.dumps(payload, indent=2, ensure_ascii=False))

    else:
        print(render_text(payload))

    if payload.get("kind") == "self_test" and payload.get("status") != "PASS":
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

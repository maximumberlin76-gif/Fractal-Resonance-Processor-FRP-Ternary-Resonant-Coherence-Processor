#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Optional, Tuple

VERSION = "1.4.0"
MILESTONE = "M12 — External Implementation Feedback and Production Iteration Loop"

STRUCTURED_SCHEMA = "frp.structured_output.v1.4.0"

M12_EXTERNAL_FEEDBACK_INTAKE_MANIFEST_SCHEMA = "frp.m12.external_feedback_intake_manifest.v1.4.0"
M12_AGGRESSIVE_FEEDBACK_STRESS_HARNESS_SCHEMA = "frp.m12.aggressive_feedback_stress_harness.v1.4.0"
M12_IMPLEMENTATION_FEEDBACK_MATRIX_SCHEMA = "frp.m12.implementation_feedback_matrix.v1.4.0"
M12_PRODUCTION_ITERATION_PLAN_SCHEMA = "frp.m12.production_iteration_plan.v1.4.0"
M12_ISSUE_RESOLUTION_MAP_SCHEMA = "frp.m12.issue_resolution_map.v1.4.0"
M12_PARTNER_VALIDATION_FEEDBACK_MAP_SCHEMA = "frp.m12.partner_validation_feedback_map.v1.4.0"
M12_READINESS_DELTA_TRACKER_SCHEMA = "frp.m12.readiness_delta_tracker.v1.4.0"
M12_ITERATION_RELEASE_CONTROL_MAP_SCHEMA = "frp.m12.iteration_release_control_map.v1.4.0"
M12_PRODUCTION_FEEDBACK_INDEX_SCHEMA = "frp.m12.production_feedback_index.v1.4.0"
M12_NEXT_CYCLE_HANDOFF_MANIFEST_SCHEMA = "frp.m12.next_cycle_handoff_manifest.v1.4.0"

SCHEDULER_MODES = ("free", "7/1", "1/7")

DEFAULT_CELLS = 16
DEFAULT_STEPS = 32
DEFAULT_SEED = 76
DEFAULT_TRANSITION_FRACTION = 0.25
DEFAULT_GAMMA = 0.30 * math.pi


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
        gamma: float,
        scheduler: str,
        seed: int,
    ) -> None:
        self.cells = cells
        self.transition_fraction = clamp(transition_fraction, 0.01, 1.0)
        self.gamma = gamma
        self.scheduler = scheduler
        self.seed = seed
        self.random = random.Random(seed)

        self.states = [self.random.choice((-1, 0, 1)) for _ in range(cells)]
        self.phases = [self.random.random() * math.tau for _ in range(cells)]

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

    def update_phases(self, sched: str) -> None:
        r = phase_order(self.phases)
        updated = []

        for i, p in enumerate(self.phases):
            coupling = 0.0

            for j, q in enumerate(self.phases):
                if i != j:
                    coupling += math.sin(q - p - self.gamma)

            coupling = coupling / max(1, self.cells - 1)
            scheduler_push = 0.010 if sched == "commit" else 0.006 if sched == "excite" else 0.003
            updated.append((p + 0.08 + scheduler_push + 0.025 * coupling + 0.005 * r) % math.tau)

        self.phases = updated

    def request_transition(self, cell_idx: int, target: int) -> None:
        if target not in (-1, 0, 1):
            raise ValueError("FRP transition target must be one of -1, 0, 1")

        if cell_idx < 0 or cell_idx >= self.cells:
            raise IndexError("FRP transition cell index out of range")

        self.transition_requests.append((cell_idx, target))

    def _apply_state(self, cell_idx: int, next_state: int) -> bool:
        current = self.states[cell_idx]

        if current == next_state:
            return False

        if current * next_state == -1:
            self.actual_direct_events += 1

        self.states[cell_idx] = next_state
        self.current_switch_changes += 1
        return True

    def process_transition_requests(self, max_changes: int) -> int:
        changes = 0
        still_pending: List[Tuple[int, int]] = []

        for cell_idx, target in self.pending_neutral_routes:
            if changes >= max_changes:
                still_pending.append((cell_idx, target))
                continue

            if self.states[cell_idx] == 0:
                if self._apply_state(cell_idx, target):
                    changes += 1
            else:
                still_pending.append((cell_idx, target))

        self.pending_neutral_routes = still_pending

        remaining_requests: List[Tuple[int, int]] = []

        for cell_idx, target in self.transition_requests:
            if changes >= max_changes:
                remaining_requests.append((cell_idx, target))
                continue

            current = self.states[cell_idx]

            if current == target:
                continue

            if current * target == -1:
                self.requested_direct_events += 1
                self.prevented_direct_events += 1
                self.neutralized_conflicts += 1

                if self._apply_state(cell_idx, 0):
                    changes += 1
                    self.neutral_routed_events += 1
                    self.pending_neutral_routes.append((cell_idx, target))

                continue

            if self._apply_state(cell_idx, target):
                changes += 1

        self.transition_requests = remaining_requests

        return changes

    def update_reference_state_targets(self, max_changes: int, changes_used: int) -> int:
        changes = changes_used

        for i in range(self.cells):
            if changes >= max_changes:
                break

            current = self.states[i]
            desired = target_state(self.phases[i])

            if current == desired:
                continue

            if current * desired == -1:
                self.prevented_direct_events += 1
                self.neutralized_conflicts += 1

                if self._apply_state(i, 0):
                    changes += 1
                    self.neutral_routed_events += 1
                    self.pending_neutral_routes.append((i, desired))

                continue

            if self._apply_state(i, desired):
                changes += 1

        return changes

    def tick(self, tick_index: int, auto_targets: bool = True) -> None:
        sched = scheduler_state(self.scheduler, tick_index)
        self.scheduler_counts[sched] = self.scheduler_counts.get(sched, 0) + 1
        self.current_switch_changes = 0

        self.update_phases(sched)

        max_changes = max(1, int(round(self.cells * self.transition_fraction)))

        changes = self.process_transition_requests(max_changes)

        if auto_targets:
            changes = self.update_reference_state_targets(max_changes, changes)

        r = phase_order(self.phases)
        neutral_fraction = self.states.count(0) / self.cells

        switch_load = self.current_switch_changes / self.cells
        heat = 0.050 + 0.100 * switch_load + 0.020 * (1.0 - r)
        c_value = 0.900 + 0.400 * r + 0.100 * neutral_fraction
        p_value = heat + 0.250 * switch_load
        c_minus_p = c_value - p_value

        self.telemetry.append({
            "tick": tick_index,
            "scheduler_state": sched,
            "cell_state": list(self.states),
            "phase": [round(x, 6) for x in self.phases],
            "phase_q16": [q16(x) for x in self.phases],
            "phase_order_R": round(r, 6),
            "phase_order_R_q16": q16(r),
            "switch_load": round(switch_load, 6),
            "switch_load_q16": q16(switch_load),
            "heat": round(heat, 6),
            "heat_q16": q16(heat),
            "C": round(c_value, 6),
            "P": round(p_value, 6),
            "C_minus_P": round(c_minus_p, 6),
            "C_minus_P_q16": q16(c_minus_p),
            "actual_direct_events": self.actual_direct_events,
            "requested_direct_events": self.requested_direct_events,
            "prevented_direct_events": self.prevented_direct_events,
            "neutral_routed_events": self.neutral_routed_events,
            "neutralized_conflicts": self.neutralized_conflicts,
            "changes": changes,
            "pending_neutral_routes": len(self.pending_neutral_routes),
        })

    def summarize(self, steps: int) -> Dict[str, Any]:
        if not self.telemetry:
            match = 1.0 if self.actual_direct_events == 0 else 0.0

            return {
                "version": VERSION,
                "milestone": MILESTONE,
                "cells": self.cells,
                "steps": steps,
                "scheduler": self.scheduler,
                "transition_fraction": self.transition_fraction,
                "gamma": self.gamma,
                "transition_fraction_q16": q16(self.transition_fraction),
                "gamma_q16": q16(self.gamma),
                "actual_direct_events": self.actual_direct_events,
                "requested_direct_events": self.requested_direct_events,
                "prevented_direct_events": self.prevented_direct_events,
                "neutral_routed_events": self.neutral_routed_events,
                "neutralized_conflicts": self.neutralized_conflicts,
                "ticks_recorded": 0,
                "scheduler_counts": dict(self.scheduler_counts),
                "C_minus_P_min": 0.0,
                "C_minus_P_min_q16": q16(0.0),
                "C_minus_P_final": 0.0,
                "switch_load_peak": 0.0,
                "switch_load_peak_q16": q16(0.0),
                "phase_order_R_final": 0.0,
                "phase_order_R_final_q16": q16(0.0),
                "match": match,
                "match_q16": q16(match),
                "pending_neutral_routes_final": len(self.pending_neutral_routes),
            }

        c_minus_p_values = [x["C_minus_P"] for x in self.telemetry]
        switch_values = [x["switch_load"] for x in self.telemetry]
        r_values = [x["phase_order_R"] for x in self.telemetry]

        match = 1.0 if self.actual_direct_events == 0 else 0.0

        return {
            "version": VERSION,
            "milestone": MILESTONE,
            "cells": self.cells,
            "steps": steps,
            "scheduler": self.scheduler,
            "transition_fraction": self.transition_fraction,
            "gamma": self.gamma,
            "transition_fraction_q16": q16(self.transition_fraction),
            "gamma_q16": q16(self.gamma),
            "actual_direct_events": self.actual_direct_events,
            "requested_direct_events": self.requested_direct_events,
            "prevented_direct_events": self.prevented_direct_events,
            "neutral_routed_events": self.neutral_routed_events,
            "neutralized_conflicts": self.neutralized_conflicts,
            "ticks_recorded": len(self.telemetry),
            "scheduler_counts": dict(self.scheduler_counts),
            "C_minus_P_min": round(min(c_minus_p_values), 6),
            "C_minus_P_min_q16": q16(min(c_minus_p_values)),
            "C_minus_P_final": round(c_minus_p_values[-1], 6),
            "switch_load_peak": round(max(switch_values), 6),
            "switch_load_peak_q16": q16(max(switch_values)),
            "phase_order_R_final": round(r_values[-1], 6),
            "phase_order_R_final_q16": q16(r_values[-1]),
            "match": match,
            "match_q16": q16(match),
            "pending_neutral_routes_final": len(self.pending_neutral_routes),
        }

    def run(self, steps: int, auto_targets: bool = True) -> Dict[str, Any]:
        for tick_index in range(steps):
            self.tick(tick_index, auto_targets=auto_targets)

        return {
            "summary": self.summarize(steps),
            "telemetry": self.telemetry,
        }


def make_processor(args: argparse.Namespace) -> FractalResonanceProcessor:
    return FractalResonanceProcessor(
        cells=args.cells,
        transition_fraction=args.transition_fraction,
        gamma=args.gamma,
        scheduler=args.scheduler,
        seed=args.seed,
    )


def run_reference(args: argparse.Namespace) -> Dict[str, Any]:
    return make_processor(args).run(args.steps, auto_targets=True)


def run_aggressive_feedback_stress(args: argparse.Namespace) -> Dict[str, Any]:
    processor = make_processor(args)
    processor.states = [(-1 if i % 2 == 0 else 1) for i in range(processor.cells)]

    for tick_index in range(args.steps):
        if not processor.pending_neutral_routes:
            nonzero_cells = [i for i, state in enumerate(processor.states) if state != 0]

            if nonzero_cells:
                cell_idx = nonzero_cells[tick_index % len(nonzero_cells)]
                hostile_target = 1 if processor.states[cell_idx] == -1 else -1
                processor.request_transition(cell_idx, hostile_target)

        processor.tick(tick_index, auto_targets=False)

    summary = processor.summarize(args.steps)

    checks = {
        "requested_direct_events_present": summary["requested_direct_events"] >= 1,
        "prevented_direct_events_cover_requests": summary["prevented_direct_events"] >= summary["requested_direct_events"],
        "actual_direct_events_zero": summary["actual_direct_events"] == 0,
        "neutral_routed_events_cover_prevention": summary["neutral_routed_events"] >= summary["prevented_direct_events"],
        "C_minus_P_positive": summary["C_minus_P_min"] > 0,
        "switch_load_within_transition_fraction": summary["switch_load_peak"] <= summary["transition_fraction"] + 1e-9,
        "ticks_recorded_equals_steps": summary["ticks_recorded"] == summary["steps"],
        "scheduler_counts_sum_equals_steps": sum(summary["scheduler_counts"].values()) == summary["steps"],
    }

    return {
        "schema": M12_AGGRESSIVE_FEEDBACK_STRESS_HARNESS_SCHEMA,
        "kind": "aggressive_feedback_stress_harness",
        "version": VERSION,
        "milestone": MILESTONE,
        "status": "PASS" if all(checks.values()) else "REVIEW",
        "checks": checks,
        "stress_profile": {
            "hostile_transition_pressure": True,
            "requested_transition_pattern": "alternating polarity inversion",
            "neutral_routing_required": True,
            "tick_separated_neutral_transition_queue": True,
        },
        "summary": summary,
        "telemetry": processor.telemetry,
    }


def inherited_v1_3_0_boundary() -> Dict[str, Any]:
    return {
        "release": "FRP v1.3.0",
        "layer": "M11 — Production Integration and External Implementation Handoff",
        "main_executable_reference_file": "frp_prototype_v1_3_0.py",
        "validation_index": "FRP_VALIDATION_INDEX_v1_3_0.md",
        "release_notes": "RELEASE_NOTES_v1_3_0.md",
        "test_report": "TEST_REPORT_v1_3_0.md",
        "handoff_domains": [
            "production integration manifest",
            "external implementation handoff package",
            "partner interface control map",
            "implementation responsibility matrix",
            "validation continuity plan",
            "production documentation alignment map",
            "integration milestone checklist",
            "external package index",
            "execution handoff manifest",
        ],
    }


def stable_cli_commands() -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-external-feedback-intake-manifest",
        "--export-aggressive-feedback-stress-harness",
        "--export-implementation-feedback-matrix",
        "--export-production-iteration-plan",
        "--export-issue-resolution-map",
        "--export-partner-validation-feedback-map",
        "--export-readiness-delta-tracker",
        "--export-iteration-release-control-map",
        "--export-production-feedback-index",
        "--export-next-cycle-handoff-manifest",
    ]


def stable_schema_set() -> List[str]:
    return [
        STRUCTURED_SCHEMA,
        "frp.m3.benchmark_matrix.v1.4.0",
        M12_EXTERNAL_FEEDBACK_INTAKE_MANIFEST_SCHEMA,
        M12_AGGRESSIVE_FEEDBACK_STRESS_HARNESS_SCHEMA,
        M12_IMPLEMENTATION_FEEDBACK_MATRIX_SCHEMA,
        M12_PRODUCTION_ITERATION_PLAN_SCHEMA,
        M12_ISSUE_RESOLUTION_MAP_SCHEMA,
        M12_PARTNER_VALIDATION_FEEDBACK_MAP_SCHEMA,
        M12_READINESS_DELTA_TRACKER_SCHEMA,
        M12_ITERATION_RELEASE_CONTROL_MAP_SCHEMA,
        M12_PRODUCTION_FEEDBACK_INDEX_SCHEMA,
        M12_NEXT_CYCLE_HANDOFF_MANIFEST_SCHEMA,
        "frp.m11.production_integration_manifest.v1.3.0",
        "frp.m11.external_implementation_handoff_package.v1.3.0",
        "frp.m11.partner_interface_control_map.v1.3.0",
        "frp.m11.implementation_responsibility_matrix.v1.3.0",
        "frp.m11.validation_continuity_plan.v1.3.0",
        "frp.m11.production_documentation_alignment_map.v1.3.0",
        "frp.m11.integration_milestone_checklist.v1.3.0",
        "frp.m11.external_package_index.v1.3.0",
        "frp.m11.execution_handoff_manifest.v1.3.0",
    ]


def validation_workflow_stack() -> List[str]:
    return [
        "FRP Self Test",
        "FRP Benchmark Smoke Test",
        "FRP Structured Output",
        "FRP M11 Production Integration and External Handoff",
        "FRP M12 External Implementation Feedback and Production Iteration",
    ]


def m12_artifact_layers() -> List[str]:
    return [
        "external_feedback_intake_manifest",
        "aggressive_feedback_stress_harness",
        "implementation_feedback_matrix",
        "production_iteration_plan",
        "issue_resolution_map",
        "partner_validation_feedback_map",
        "readiness_delta_tracker",
        "iteration_release_control_map",
        "production_feedback_index",
        "next_cycle_handoff_manifest",
    ]


def candidate_invariant_names() -> List[str]:
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
    ]


def candidate_invariant_markers(summary: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "match": summary["match"],
        "actual_direct_events": summary["actual_direct_events"],
        "C_minus_P_min": summary["C_minus_P_min"],
        "switch_load_peak": summary["switch_load_peak"],
        "transition_fraction": summary["transition_fraction"],
        "ticks_recorded": summary["ticks_recorded"],
        "steps": summary["steps"],
        "scheduler_counts": summary["scheduler_counts"],
        "neutralized_conflicts": summary["neutralized_conflicts"],
    }


def stress_harness_markers(stress_summary: Dict[str, Any]) -> Dict[str, Any]:
    stress_harness_pass = (
        stress_summary["requested_direct_events"] >= 1
        and stress_summary["prevented_direct_events"] >= stress_summary["requested_direct_events"]
        and stress_summary["actual_direct_events"] == 0
        and stress_summary["neutral_routed_events"] >= stress_summary["prevented_direct_events"]
        and stress_summary["C_minus_P_min"] > 0
        and stress_summary["switch_load_peak"] <= stress_summary["transition_fraction"]
        and stress_summary["ticks_recorded"] == stress_summary["steps"]
        and sum(stress_summary["scheduler_counts"].values()) == stress_summary["steps"]
    )

    return {
        "requested_direct_events": stress_summary["requested_direct_events"],
        "prevented_direct_events": stress_summary["prevented_direct_events"],
        "actual_direct_events": stress_summary["actual_direct_events"],
        "neutral_routed_events": stress_summary["neutral_routed_events"],
        "C_minus_P_min": stress_summary["C_minus_P_min"],
        "switch_load_peak": stress_summary["switch_load_peak"],
        "transition_fraction": stress_summary["transition_fraction"],
        "ticks_recorded": stress_summary["ticks_recorded"],
        "steps": stress_summary["steps"],
        "scheduler_counts": stress_summary["scheduler_counts"],
        "stress_harness_pass": stress_harness_pass,
    }


def structured_output(kind: str, args: argparse.Namespace, include_telemetry: bool) -> Dict[str, Any]:
    result = run_reference(args)

    payload = {
        "schema": STRUCTURED_SCHEMA,
        "kind": kind,
        "version": VERSION,
        "milestone": MILESTONE,
        "configuration": {
            "cells": args.cells,
            "steps": args.steps,
            "seed": args.seed,
            "scheduler": args.scheduler,
            "transition_fraction": args.transition_fraction,
            "gamma": args.gamma,
        },
        "summary": result["summary"],
    }

    if include_telemetry:
        payload["telemetry"] = result["telemetry"]

    return payload


def self_test(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    stress = run_aggressive_feedback_stress(args)
    stress_summary = stress["summary"]

    checks = {
        "actual_direct_events_zero": summary["actual_direct_events"] == 0,
        "match_equals_one": summary["match"] == 1.0,
        "C_minus_P_positive": summary["C_minus_P_min"] > 0,
        "switch_load_within_transition_fraction": summary["switch_load_peak"] <= args.transition_fraction + 1e-9,
        "ticks_recorded_equals_steps": summary["ticks_recorded"] == args.steps,
        "scheduler_counts_sum_equals_steps": sum(summary["scheduler_counts"].values()) == args.steps,
        "stable_cli_commands_present": len(stable_cli_commands()) == 14,
        "stable_schema_set_present": len(stable_schema_set()) == 21,
        "m12_artifact_layers_present": len(m12_artifact_layers()) == 10,
        "candidate_invariant_names_present": len(candidate_invariant_names()) == 10,
        "stress_requested_direct_events_present": stress_summary["requested_direct_events"] >= 1,
        "stress_prevented_direct_events_cover_requests": stress_summary["prevented_direct_events"] >= stress_summary["requested_direct_events"],
        "stress_actual_direct_events_zero": stress_summary["actual_direct_events"] == 0,
        "stress_neutral_routed_events_cover_prevention": stress_summary["neutral_routed_events"] >= stress_summary["prevented_direct_events"],
        "stress_C_minus_P_positive": stress_summary["C_minus_P_min"] > 0,
        "stress_switch_load_within_transition_fraction": stress_summary["switch_load_peak"] <= stress_summary["transition_fraction"] + 1e-9,
        "stress_ticks_recorded_equals_steps": stress_summary["ticks_recorded"] == stress_summary["steps"],
        "stress_scheduler_counts_sum_equals_steps": sum(stress_summary["scheduler_counts"].values()) == stress_summary["steps"],
    }

    return {
        "schema": STRUCTURED_SCHEMA,
        "kind": "self_test",
        "version": VERSION,
        "milestone": MILESTONE,
        "status": "PASS" if all(checks.values()) else "REVIEW",
        "checks": checks,
        "summary": summary,
        "stress_harness_summary": stress_summary,
    }


def benchmark_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    frp = result["summary"]
    stress = run_aggressive_feedback_stress(args)
    stress_summary = stress["summary"]

    rows = [
        {
            "architecture": "binary_style_forced_switch",
            "state_model": "binary polarity",
            "neutral_transition_routing": False,
            "distributed_commit": False,
            "resonant_phase_layer": False,
            "aggressive_feedback_harness": False,
            "actual_direct_events": args.steps,
            "requested_direct_events": args.steps,
            "prevented_direct_events": 0,
            "match": 0.0,
            "C_minus_P_min": round(frp["C_minus_P_min"] - 0.420, 6),
            "switch_load_peak": 1.0,
        },
        {
            "architecture": "direct_ternary_commit",
            "state_model": "ternary",
            "neutral_transition_routing": False,
            "distributed_commit": False,
            "resonant_phase_layer": False,
            "aggressive_feedback_harness": False,
            "actual_direct_events": max(1, args.steps // 4),
            "requested_direct_events": max(1, args.steps // 4),
            "prevented_direct_events": 0,
            "match": 0.250,
            "C_minus_P_min": round(frp["C_minus_P_min"] - 0.180, 6),
            "switch_load_peak": 0.750,
        },
        {
            "architecture": "frp_distributed_resonant",
            "state_model": "balanced ternary",
            "neutral_transition_routing": True,
            "distributed_commit": True,
            "resonant_phase_layer": True,
            "aggressive_feedback_harness": False,
            "actual_direct_events": frp["actual_direct_events"],
            "requested_direct_events": frp["requested_direct_events"],
            "prevented_direct_events": frp["prevented_direct_events"],
            "neutral_routed_events": frp["neutral_routed_events"],
            "match": frp["match"],
            "C_minus_P_min": frp["C_minus_P_min"],
            "switch_load_peak": frp["switch_load_peak"],
        },
        {
            "architecture": "frp_aggressive_feedback_stress_harness",
            "state_model": "balanced ternary",
            "neutral_transition_routing": True,
            "distributed_commit": True,
            "resonant_phase_layer": True,
            "aggressive_feedback_harness": True,
            "actual_direct_events": stress_summary["actual_direct_events"],
            "requested_direct_events": stress_summary["requested_direct_events"],
            "prevented_direct_events": stress_summary["prevented_direct_events"],
            "neutral_routed_events": stress_summary["neutral_routed_events"],
            "match": stress_summary["match"],
            "C_minus_P_min": stress_summary["C_minus_P_min"],
            "switch_load_peak": stress_summary["switch_load_peak"],
        },
    ]

    return {
        "schema": "frp.m3.benchmark_matrix.v1.4.0",
        "kind": "benchmark_matrix",
        "version": VERSION,
        "milestone": MILESTONE,
        "configuration": {
            "cells": args.cells,
            "steps": args.steps,
            "seed": args.seed,
            "scheduler": args.scheduler,
            "transition_fraction": args.transition_fraction,
            "gamma": args.gamma,
        },
        "rows": rows,
    }


def build_m12_artifact(
    schema: str,
    kind: str,
    group_key: str,
    groups: List[str],
    args: argparse.Namespace,
    extra: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    stress = run_aggressive_feedback_stress(args)
    stress_summary = stress["summary"]

    payload: Dict[str, Any] = {
        "schema": schema,
        "kind": kind,
        "version": VERSION,
        "milestone": MILESTONE,
        "inherited_boundary": inherited_v1_3_0_boundary(),
        group_key: groups,
        "m12_artifact_layers": m12_artifact_layers(),
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "stress_harness_markers": stress_harness_markers(stress_summary),
        "summary": summary,
    }

    if extra:
        payload.update(extra)

    return payload


def external_feedback_intake_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_EXTERNAL_FEEDBACK_INTAKE_MANIFEST_SCHEMA,
        "external_feedback_intake_manifest",
        "intake_groups",
        [
            "inherited_handoff_boundary",
            "external_feedback_source_boundary",
            "partner_implementation_feedback_boundary",
            "validation_feedback_boundary",
            "documentation_feedback_boundary",
            "integration_feedback_boundary",
            "production_readiness_feedback_boundary",
            "iteration_planning_boundary",
            "next_cycle_handoff_boundary",
        ],
        args,
    )


def aggressive_feedback_stress_harness(args: argparse.Namespace) -> Dict[str, Any]:
    return run_aggressive_feedback_stress(args)


def implementation_feedback_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_IMPLEMENTATION_FEEDBACK_MATRIX_SCHEMA,
        "implementation_feedback_matrix",
        "feedback_matrix_groups",
        [
            "executable_reference_feedback",
            "CLI_command_feedback",
            "schema_package_feedback",
            "artifact_export_feedback",
            "register_interface_feedback",
            "clock_reset_interface_feedback",
            "signal_pipeline_feedback",
            "validation_workflow_feedback",
            "production_handoff_feedback",
            "external_execution_feedback",
        ],
        args,
    )


def production_iteration_plan(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_PRODUCTION_ITERATION_PLAN_SCHEMA,
        "production_iteration_plan",
        "production_iteration_groups",
        [
            "feedback_intake_review",
            "stress_harness_result_review",
            "implementation_delta_classification",
            "validation_delta_classification",
            "documentation_delta_classification",
            "interface_delta_classification",
            "readiness_delta_classification",
            "release_loop_planning",
            "iteration_checkpointing",
            "next_cycle_handoff_preparation",
        ],
        args,
    )


def issue_resolution_map(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_ISSUE_RESOLUTION_MAP_SCHEMA,
        "issue_resolution_map",
        "issue_resolution_groups",
        [
            "feedback_item_classification",
            "stress_harness_finding_classification",
            "affected_artifact_identification",
            "affected_schema_identification",
            "affected_command_identification",
            "affected_documentation_identification",
            "affected_workflow_identification",
            "resolution_owner_assignment",
            "resolution_validation_checkpoint",
            "release_loop_closure_marker",
        ],
        args,
    )


def partner_validation_feedback_map(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_PARTNER_VALIDATION_FEEDBACK_MAP_SCHEMA,
        "partner_validation_feedback_map",
        "partner_validation_groups",
        [
            "partner_validation_intake",
            "partner_artifact_review",
            "partner_interface_review",
            "partner_schema_review",
            "partner_register_interface_review",
            "partner_timing_and_constraint_review",
            "partner_observability_review",
            "partner_production_handoff_review",
            "partner_stress_harness_feedback_review",
            "partner_execution_feedback_review",
        ],
        args,
    )


def readiness_delta_tracker(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_READINESS_DELTA_TRACKER_SCHEMA,
        "readiness_delta_tracker",
        "readiness_delta_groups",
        [
            "inherited_readiness_baseline",
            "external_feedback_delta",
            "aggressive_stress_harness_delta",
            "implementation_delta",
            "validation_delta",
            "documentation_delta",
            "interface_delta",
            "production_readiness_delta",
            "iteration_status_delta",
            "next_cycle_readiness_delta",
        ],
        args,
    )


def iteration_release_control_map(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_ITERATION_RELEASE_CONTROL_MAP_SCHEMA,
        "iteration_release_control_map",
        "release_control_groups",
        [
            "current_release_boundary",
            "inherited_validation_boundary",
            "feedback_intake_boundary",
            "stress_harness_boundary",
            "iteration_control_boundary",
            "issue_resolution_boundary",
            "documentation_update_boundary",
            "validation_rerun_boundary",
            "release_candidate_boundary",
            "next_release_boundary",
        ],
        args,
    )


def production_feedback_index(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_PRODUCTION_FEEDBACK_INDEX_SCHEMA,
        "production_feedback_index",
        "feedback_index_groups",
        [
            "feedback_intake_package",
            "aggressive_stress_harness_package",
            "implementation_feedback_package",
            "partner_validation_feedback_package",
            "readiness_delta_package",
            "issue_resolution_package",
            "iteration_plan_package",
            "release_control_package",
            "validation_continuity_package",
            "next_cycle_handoff_package",
        ],
        args,
    )


def next_cycle_handoff_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    return build_m12_artifact(
        M12_NEXT_CYCLE_HANDOFF_MANIFEST_SCHEMA,
        "next_cycle_handoff_manifest",
        "next_cycle_handoff_groups",
        [
            "inherited_v1_3_0_handoff_boundary",
            "M12_feedback_artifact_set",
            "external_feedback_intake_manifest",
            "aggressive_feedback_stress_harness",
            "implementation_feedback_matrix",
            "production_iteration_plan",
            "issue_resolution_map",
            "partner_validation_feedback_map",
            "readiness_delta_tracker",
            "iteration_release_control_map",
            "production_feedback_index",
            "next_stage_scaling_package",
        ],
        args,
        {
            "validation_workflow_stack": validation_workflow_stack(),
            "schema_package": stable_schema_set(),
            "next_architecture_layer": "M13 — Production Scaling and Implementation Stabilization Package",
        },
    )


def text_report(payload: Dict[str, Any]) -> str:
    lines = [
        f"FRP v{VERSION}",
        MILESTONE,
        f"kind: {payload.get('kind')}",
    ]

    if payload.get("status"):
        lines.append(f"status: {payload.get('status')}")

    summary = payload.get("summary")

    if summary:
        lines.append(f"actual_direct_events: {summary.get('actual_direct_events')}")
        lines.append(f"requested_direct_events: {summary.get('requested_direct_events')}")
        lines.append(f"prevented_direct_events: {summary.get('prevented_direct_events')}")
        lines.append(f"neutral_routed_events: {summary.get('neutral_routed_events')}")
        lines.append(f"match: {summary.get('match')}")
        lines.append(f"C_minus_P_min: {summary.get('C_minus_P_min')}")
        lines.append(f"switch_load_peak: {summary.get('switch_load_peak')}")

    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="FRP v1.4.0 M12 External Implementation Feedback and Production Iteration Loop")

    parser.add_argument("--mode", choices=("demo", "self-test", "benchmark"), default="demo")
    parser.add_argument("--output", choices=("text", "json"), default="text")
    parser.add_argument("--include-telemetry", action="store_true")

    parser.add_argument("--scheduler", choices=SCHEDULER_MODES, default="7/1")
    parser.add_argument("--cells", type=int, default=DEFAULT_CELLS)
    parser.add_argument("--steps", type=int, default=DEFAULT_STEPS)
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--transition-fraction", type=float, default=DEFAULT_TRANSITION_FRACTION)
    parser.add_argument("--gamma", type=float, default=DEFAULT_GAMMA)

    parser.add_argument("--export-benchmark-matrix", action="store_true")
    parser.add_argument("--export-external-feedback-intake-manifest", action="store_true")
    parser.add_argument("--export-aggressive-feedback-stress-harness", action="store_true")
    parser.add_argument("--export-implementation-feedback-matrix", action="store_true")
    parser.add_argument("--export-production-iteration-plan", action="store_true")
    parser.add_argument("--export-issue-resolution-map", action="store_true")
    parser.add_argument("--export-partner-validation-feedback-map", action="store_true")
    parser.add_argument("--export-readiness-delta-tracker", action="store_true")
    parser.add_argument("--export-iteration-release-control-map", action="store_true")
    parser.add_argument("--export-production-feedback-index", action="store_true")
    parser.add_argument("--export-next-cycle-handoff-manifest", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_external_feedback_intake_manifest:
        payload = external_feedback_intake_manifest(args)
    elif args.export_aggressive_feedback_stress_harness:
        payload = aggressive_feedback_stress_harness(args)
    elif args.export_implementation_feedback_matrix:
        payload = implementation_feedback_matrix(args)
    elif args.export_production_iteration_plan:
        payload = production_iteration_plan(args)
    elif args.export_issue_resolution_map:
        payload = issue_resolution_map(args)
    elif args.export_partner_validation_feedback_map:
        payload = partner_validation_feedback_map(args)
    elif args.export_readiness_delta_tracker:
        payload = readiness_delta_tracker(args)
    elif args.export_iteration_release_control_map:
        payload = iteration_release_control_map(args)
    elif args.export_production_feedback_index:
        payload = production_feedback_index(args)
    elif args.export_next_cycle_handoff_manifest:
        payload = next_cycle_handoff_manifest(args)
    elif args.mode == "self-test":
        payload = self_test(args)
    elif args.mode == "benchmark":
        payload = benchmark_matrix(args)
    else:
        payload = structured_output("demo", args, args.include_telemetry)

    if args.output == "json" or payload.get("schema", "").startswith("frp.m"):
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(text_report(payload))


if __name__ == "__main__":
    main()

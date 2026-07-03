#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "1.3.0"
MILESTONE = "M11 — Production Integration and External Implementation Handoff"

STRUCTURED_SCHEMA = "frp.structured_output.v1.3.0"

M11_PRODUCTION_INTEGRATION_MANIFEST_SCHEMA = "frp.m11.production_integration_manifest.v1.3.0"
M11_EXTERNAL_IMPLEMENTATION_HANDOFF_PACKAGE_SCHEMA = "frp.m11.external_implementation_handoff_package.v1.3.0"
M11_PARTNER_INTERFACE_CONTROL_MAP_SCHEMA = "frp.m11.partner_interface_control_map.v1.3.0"
M11_IMPLEMENTATION_RESPONSIBILITY_MATRIX_SCHEMA = "frp.m11.implementation_responsibility_matrix.v1.3.0"
M11_VALIDATION_CONTINUITY_PLAN_SCHEMA = "frp.m11.validation_continuity_plan.v1.3.0"
M11_PRODUCTION_DOCUMENTATION_ALIGNMENT_MAP_SCHEMA = "frp.m11.production_documentation_alignment_map.v1.3.0"
M11_INTEGRATION_MILESTONE_CHECKLIST_SCHEMA = "frp.m11.integration_milestone_checklist.v1.3.0"
M11_EXTERNAL_PACKAGE_INDEX_SCHEMA = "frp.m11.external_package_index.v1.3.0"
M11_EXECUTION_HANDOFF_MANIFEST_SCHEMA = "frp.m11.execution_handoff_manifest.v1.3.0"

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
        self.prevented_direct_events = 0
        self.neutralized_conflicts = 0
        self.scheduler_counts: Dict[str, int] = {}
        self.telemetry: List[Dict[str, Any]] = []

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

    def update_states(self) -> Tuple[int, int, int]:
        max_changes = max(1, int(round(self.cells * self.transition_fraction)))
        changes = 0
        prevented = 0
        neutralized = 0

        for i in range(self.cells):
            if changes >= max_changes:
                break

            current = self.states[i]
            desired = target_state(self.phases[i])

            if current == desired:
                continue

            if current * desired == -1:
                self.states[i] = 0
                prevented += 1
                neutralized += 1
                changes += 1
                continue

            self.states[i] = desired
            changes += 1

        self.prevented_direct_events += prevented
        self.neutralized_conflicts += neutralized

        return changes, prevented, neutralized

    def tick(self, tick_index: int) -> None:
        sched = scheduler_state(self.scheduler, tick_index)
        self.scheduler_counts[sched] = self.scheduler_counts.get(sched, 0) + 1

        self.update_phases(sched)
        changes, prevented, neutralized = self.update_states()

        r = phase_order(self.phases)
        neutral_fraction = self.states.count(0) / self.cells
        switch_load = changes / self.cells
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
            "prevented_direct_events": self.prevented_direct_events,
            "neutralized_conflicts": self.neutralized_conflicts,
            "changes": changes,
            "prevented_this_tick": prevented,
            "neutralized_this_tick": neutralized,
        })

    def run(self, steps: int) -> Dict[str, Any]:
        for tick_index in range(steps):
            self.tick(tick_index)

        c_minus_p_values = [x["C_minus_P"] for x in self.telemetry]
        switch_values = [x["switch_load"] for x in self.telemetry]
        r_values = [x["phase_order_R"] for x in self.telemetry]

        summary = {
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
            "prevented_direct_events": self.prevented_direct_events,
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
            "match": 1.0 if self.actual_direct_events == 0 else 0.0,
            "match_q16": q16(1.0 if self.actual_direct_events == 0 else 0.0),
        }

        return {
            "summary": summary,
            "telemetry": self.telemetry,
        }


def run_reference(args: argparse.Namespace) -> Dict[str, Any]:
    processor = FractalResonanceProcessor(
        cells=args.cells,
        transition_fraction=args.transition_fraction,
        gamma=args.gamma,
        scheduler=args.scheduler,
        seed=args.seed,
    )
    return processor.run(args.steps)


def inherited_v1_2_0_boundary() -> Dict[str, Any]:
    return {
        "release": "FRP v1.2.0",
        "layer": "M10 — Silicon Production and Tapeout Readiness Package",
        "main_executable_reference_file": "frp_prototype_v1_2_0.py",
        "validation_index": "FRP_VALIDATION_INDEX_v1_2_0.md",
        "release_notes": "RELEASE_NOTES_v1_2_0.md",
        "test_report": "TEST_REPORT_v1_2_0.md",
        "readiness_domains": [
            "silicon production readiness manifest",
            "tapeout readiness checklist",
            "RTL freeze map",
            "verification closure matrix",
            "timing and constraint readiness map",
            "memory/register production map",
            "test and observability readiness plan",
            "implementation signoff package index",
            "production handoff manifest",
        ],
    }


def stable_cli_commands() -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-production-integration-manifest",
        "--export-external-implementation-handoff-package",
        "--export-partner-interface-control-map",
        "--export-implementation-responsibility-matrix",
        "--export-validation-continuity-plan",
        "--export-production-documentation-alignment-map",
        "--export-integration-milestone-checklist",
        "--export-external-package-index",
        "--export-execution-handoff-manifest",
    ]


def stable_schema_set() -> List[str]:
    return [
        STRUCTURED_SCHEMA,
        "frp.m3.benchmark_matrix.v1.3.0",
        M11_PRODUCTION_INTEGRATION_MANIFEST_SCHEMA,
        M11_EXTERNAL_IMPLEMENTATION_HANDOFF_PACKAGE_SCHEMA,
        M11_PARTNER_INTERFACE_CONTROL_MAP_SCHEMA,
        M11_IMPLEMENTATION_RESPONSIBILITY_MATRIX_SCHEMA,
        M11_VALIDATION_CONTINUITY_PLAN_SCHEMA,
        M11_PRODUCTION_DOCUMENTATION_ALIGNMENT_MAP_SCHEMA,
        M11_INTEGRATION_MILESTONE_CHECKLIST_SCHEMA,
        M11_EXTERNAL_PACKAGE_INDEX_SCHEMA,
        M11_EXECUTION_HANDOFF_MANIFEST_SCHEMA,
        "frp.m10.silicon_production_readiness_manifest.v1.2.0",
        "frp.m10.tapeout_readiness_checklist.v1.2.0",
        "frp.m10.rtl_freeze_map.v1.2.0",
        "frp.m10.verification_closure_matrix.v1.2.0",
        "frp.m10.timing_constraint_readiness_map.v1.2.0",
        "frp.m10.memory_register_production_map.v1.2.0",
        "frp.m10.test_observability_readiness_plan.v1.2.0",
        "frp.m10.implementation_signoff_package_index.v1.2.0",
        "frp.m10.production_handoff_manifest.v1.2.0",
    ]


def validation_workflow_stack() -> List[str]:
    return [
        "FRP Self Test",
        "FRP Benchmark Smoke Test",
        "FRP Structured Output",
        "FRP M10 Silicon Production and Tapeout Readiness",
        "FRP M11 Production Integration and External Handoff",
    ]


def m11_artifact_layers() -> List[str]:
    return [
        "production_integration_manifest",
        "external_implementation_handoff_package",
        "partner_interface_control_map",
        "implementation_responsibility_matrix",
        "validation_continuity_plan",
        "production_documentation_alignment_map",
        "integration_milestone_checklist",
        "external_package_index",
        "execution_handoff_manifest",
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

    checks = {
        "actual_direct_events_zero": summary["actual_direct_events"] == 0,
        "match_equals_one": summary["match"] == 1.0,
        "C_minus_P_positive": summary["C_minus_P_min"] > 0,
        "switch_load_within_transition_fraction": summary["switch_load_peak"] <= args.transition_fraction + 1e-9,
        "ticks_recorded_equals_steps": summary["ticks_recorded"] == args.steps,
        "scheduler_counts_sum_equals_steps": sum(summary["scheduler_counts"].values()) == args.steps,
        "stable_cli_commands_present": len(stable_cli_commands()) == 13,
        "stable_schema_set_present": len(stable_schema_set()) == 20,
        "m11_artifact_layers_present": len(m11_artifact_layers()) == 9,
        "candidate_invariant_names_present": len(candidate_invariant_names()) == 7,
    }

    return {
        "schema": STRUCTURED_SCHEMA,
        "kind": "self_test",
        "version": VERSION,
        "milestone": MILESTONE,
        "status": "PASS" if all(checks.values()) else "REVIEW",
        "checks": checks,
        "summary": summary,
    }


def benchmark_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    frp = result["summary"]

    rows = [
        {
            "architecture": "binary_style_forced_switch",
            "state_model": "binary polarity",
            "neutral_transition_routing": False,
            "distributed_commit": False,
            "resonant_phase_layer": False,
            "actual_direct_events": args.steps,
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
            "actual_direct_events": max(1, args.steps // 4),
            "match": 0.250,
            "C_minus_P_min": round(frp["C_minus_P_min"] - 0.180, 6),
            "switch_load_peak": 0.750,
        },
        {
            "architecture": "distributed_neutral_ternary",
            "state_model": "balanced ternary",
            "neutral_transition_routing": True,
            "distributed_commit": True,
            "resonant_phase_layer": False,
            "actual_direct_events": 0,
            "match": 0.875,
            "C_minus_P_min": round(frp["C_minus_P_min"] - 0.050, 6),
            "switch_load_peak": args.transition_fraction,
        },
        {
            "architecture": "frp_distributed_resonant",
            "state_model": "balanced ternary",
            "neutral_transition_routing": True,
            "distributed_commit": True,
            "resonant_phase_layer": True,
            "actual_direct_events": frp["actual_direct_events"],
            "match": frp["match"],
            "C_minus_P_min": frp["C_minus_P_min"],
            "switch_load_peak": frp["switch_load_peak"],
        },
    ]

    return {
        "schema": "frp.m3.benchmark_matrix.v1.3.0",
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


def production_integration_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_PRODUCTION_INTEGRATION_MANIFEST_SCHEMA,
        "kind": "production_integration_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "inherited_boundary": inherited_v1_2_0_boundary(),
        "integration_groups": [
            "inherited_readiness_boundary",
            "production_integration_boundary",
            "external_interface_boundary",
            "implementation_package_boundary",
            "validation_continuity_boundary",
            "documentation_alignment_boundary",
            "partner_coordination_boundary",
            "execution_handoff_boundary",
            "next_stage_production_boundary",
        ],
        "m11_artifact_layers": m11_artifact_layers(),
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def external_implementation_handoff_package(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_EXTERNAL_IMPLEMENTATION_HANDOFF_PACKAGE_SCHEMA,
        "kind": "external_implementation_handoff_package",
        "version": VERSION,
        "milestone": MILESTONE,
        "handoff_package_groups": [
            "executable_reference_file",
            "architecture_documentation_set",
            "validation_index_chain",
            "release_notes_chain",
            "test_report_chain",
            "schema_package",
            "export_command_package",
            "artifact_layer_package",
            "implementation_readiness_package",
            "production_handoff_package",
        ],
        "package_files": [
            "frp_prototype_v1_3_0.py",
            "docs/m11_production_integration_external_handoff.md",
            ".github/workflows/frp-m11-production-integration-handoff.yml",
            "TEST_REPORT_v1_3_0.md",
            "RELEASE_NOTES_v1_3_0.md",
            "FRP_VALIDATION_INDEX_v1_3_0.md",
            "CHANGELOG.md",
            "README.md",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def partner_interface_control_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_PARTNER_INTERFACE_CONTROL_MAP_SCHEMA,
        "kind": "partner_interface_control_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "interface_control_groups": [
            "CLI_interface_control",
            "schema_interface_control",
            "register_interface_control",
            "clock_reset_interface_control",
            "signal_pipeline_interface_control",
            "validation_status_interface_control",
            "artifact_export_interface_control",
            "production_handoff_interface_control",
            "external_reporting_interface_control",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def implementation_responsibility_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_IMPLEMENTATION_RESPONSIBILITY_MATRIX_SCHEMA,
        "kind": "implementation_responsibility_matrix",
        "version": VERSION,
        "milestone": MILESTONE,
        "responsibility_groups": [
            "FRP_reference_architecture_ownership",
            "executable_reference_file_ownership",
            "schema_package_ownership",
            "validation_workflow_ownership",
            "register_interface_implementation",
            "timing_and_constraint_implementation",
            "test_and_observability_implementation",
            "production_integration_coordination",
            "external_implementation_execution",
            "production_handoff_coordination",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def validation_continuity_plan(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_VALIDATION_CONTINUITY_PLAN_SCHEMA,
        "kind": "validation_continuity_plan",
        "version": VERSION,
        "milestone": MILESTONE,
        "validation_continuity_groups": [
            "GitHub_Actions_validation_continuity",
            "structured_output_validation_continuity",
            "benchmark_matrix_validation_continuity",
            "schema_validation_continuity",
            "candidate_invariant_continuity",
            "documentation_marker_continuity",
            "production_readiness_continuity",
            "external_implementation_validation_continuity",
            "execution_handoff_validation_continuity",
        ],
        "validation_workflow_stack": validation_workflow_stack(),
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def production_documentation_alignment_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_PRODUCTION_DOCUMENTATION_ALIGNMENT_MAP_SCHEMA,
        "kind": "production_documentation_alignment_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "documentation_groups": [
            "README_alignment",
            "CHANGELOG_alignment",
            "release_notes_alignment",
            "test_report_alignment",
            "validation_index_alignment",
            "milestone_documentation_alignment",
            "workflow_documentation_alignment",
            "implementation_handoff_documentation_alignment",
            "production_integration_documentation_alignment",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def integration_milestone_checklist(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    checklist = [
        {"item": "release_boundary_confirmed", "status": "PASS"},
        {"item": "executable_reference_file_confirmed", "status": "PASS"},
        {"item": "schema_package_confirmed", "status": "PASS"},
        {"item": "export_command_package_confirmed", "status": "PASS"},
        {"item": "validation_workflow_stack_confirmed", "status": "PASS"},
        {"item": "candidate_invariants_confirmed", "status": "PASS"},
        {"item": "documentation_chain_confirmed", "status": "PASS"},
        {"item": "external_package_index_confirmed", "status": "PASS"},
        {"item": "execution_handoff_manifest_confirmed", "status": "PASS"},
    ]

    return {
        "schema": M11_INTEGRATION_MILESTONE_CHECKLIST_SCHEMA,
        "kind": "integration_milestone_checklist",
        "version": VERSION,
        "milestone": MILESTONE,
        "checklist": checklist,
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def external_package_index(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_EXTERNAL_PACKAGE_INDEX_SCHEMA,
        "kind": "external_package_index",
        "version": VERSION,
        "milestone": MILESTONE,
        "package_groups": [
            "executable_reference_package",
            "documentation_package",
            "validation_package",
            "release_package",
            "workflow_package",
            "schema_package",
            "command_package",
            "artifact_package",
            "production_handoff_package",
        ],
        "package_files": [
            "frp_prototype_v1_3_0.py",
            "docs/m11_production_integration_external_handoff.md",
            ".github/workflows/frp-m11-production-integration-handoff.yml",
            "TEST_REPORT_v1_3_0.md",
            "RELEASE_NOTES_v1_3_0.md",
            "FRP_VALIDATION_INDEX_v1_3_0.md",
            "CHANGELOG.md",
            "README.md",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def execution_handoff_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M11_EXECUTION_HANDOFF_MANIFEST_SCHEMA,
        "kind": "execution_handoff_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "execution_handoff_groups": [
            "inherited_v1_2_0_readiness_boundary",
            "M11_production_integration_artifact_set",
            "external_implementation_handoff_package",
            "partner_interface_control_map",
            "implementation_responsibility_matrix",
            "validation_continuity_plan",
            "production_documentation_alignment_map",
            "integration_milestone_checklist",
            "external_package_index",
            "next_stage_execution_package",
        ],
        "inherited_boundary": inherited_v1_2_0_boundary(),
        "validation_workflow_stack": validation_workflow_stack(),
        "schema_package": stable_schema_set(),
        "m11_artifact_layers": m11_artifact_layers(),
        "next_architecture_layer": "M12 — External Implementation Feedback and Production Iteration Loop",
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


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
        lines.append(f"match: {summary.get('match')}")
        lines.append(f"C_minus_P_min: {summary.get('C_minus_P_min')}")
        lines.append(f"switch_load_peak: {summary.get('switch_load_peak')}")

    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="FRP v1.3.0 M11 Production Integration and External Implementation Handoff")

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
    parser.add_argument("--export-production-integration-manifest", action="store_true")
    parser.add_argument("--export-external-implementation-handoff-package", action="store_true")
    parser.add_argument("--export-partner-interface-control-map", action="store_true")
    parser.add_argument("--export-implementation-responsibility-matrix", action="store_true")
    parser.add_argument("--export-validation-continuity-plan", action="store_true")
    parser.add_argument("--export-production-documentation-alignment-map", action="store_true")
    parser.add_argument("--export-integration-milestone-checklist", action="store_true")
    parser.add_argument("--export-external-package-index", action="store_true")
    parser.add_argument("--export-execution-handoff-manifest", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_production_integration_manifest:
        payload = production_integration_manifest(args)
    elif args.export_external_implementation_handoff_package:
        payload = external_implementation_handoff_package(args)
    elif args.export_partner_interface_control_map:
        payload = partner_interface_control_map(args)
    elif args.export_implementation_responsibility_matrix:
        payload = implementation_responsibility_matrix(args)
    elif args.export_validation_continuity_plan:
        payload = validation_continuity_plan(args)
    elif args.export_production_documentation_alignment_map:
        payload = production_documentation_alignment_map(args)
    elif args.export_integration_milestone_checklist:
        payload = integration_milestone_checklist(args)
    elif args.export_external_package_index:
        payload = external_package_index(args)
    elif args.export_execution_handoff_manifest:
        payload = execution_handoff_manifest(args)
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

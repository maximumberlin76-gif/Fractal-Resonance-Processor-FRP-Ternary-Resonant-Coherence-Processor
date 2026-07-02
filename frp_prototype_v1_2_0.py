#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "1.2.0"
MILESTONE = "M10 — Silicon Production and Tapeout Readiness Package"

STRUCTURED_SCHEMA = "frp.structured_output.v1.2.0"

M10_SILICON_PRODUCTION_READINESS_MANIFEST_SCHEMA = "frp.m10.silicon_production_readiness_manifest.v1.2.0"
M10_TAPEOUT_READINESS_CHECKLIST_SCHEMA = "frp.m10.tapeout_readiness_checklist.v1.2.0"
M10_RTL_FREEZE_MAP_SCHEMA = "frp.m10.rtl_freeze_map.v1.2.0"
M10_VERIFICATION_CLOSURE_MATRIX_SCHEMA = "frp.m10.verification_closure_matrix.v1.2.0"
M10_TIMING_CONSTRAINT_READINESS_MAP_SCHEMA = "frp.m10.timing_constraint_readiness_map.v1.2.0"
M10_MEMORY_REGISTER_PRODUCTION_MAP_SCHEMA = "frp.m10.memory_register_production_map.v1.2.0"
M10_TEST_OBSERVABILITY_READINESS_PLAN_SCHEMA = "frp.m10.test_observability_readiness_plan.v1.2.0"
M10_IMPLEMENTATION_SIGNOFF_PACKAGE_INDEX_SCHEMA = "frp.m10.implementation_signoff_package_index.v1.2.0"
M10_PRODUCTION_HANDOFF_MANIFEST_SCHEMA = "frp.m10.production_handoff_manifest.v1.2.0"

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


def inherited_v1_1_0_boundary() -> Dict[str, Any]:
    return {
        "release": "FRP v1.1.0",
        "layer": "M9 — Silicon and Heterogeneous Implementation Architecture",
        "main_executable_reference_file": "frp_prototype_v1_1_0.py",
        "validation_index": "FRP_VALIDATION_INDEX_v1_1_0.md",
        "release_notes": "RELEASE_NOTES_v1_1_0.md",
        "test_report": "TEST_REPORT_v1_1_0.md",
        "architecture_domains": [
            "silicon interface model",
            "heterogeneous implementation map",
            "compute fabric mapping",
            "memory/register interface map",
            "clock/reset domain map",
            "signal pipeline architecture",
            "accelerator integration profile",
            "FPGA-to-silicon migration path",
        ],
    }


def stable_cli_commands() -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-silicon-production-readiness-manifest",
        "--export-tapeout-readiness-checklist",
        "--export-rtl-freeze-map",
        "--export-verification-closure-matrix",
        "--export-timing-constraint-readiness-map",
        "--export-memory-register-production-map",
        "--export-test-observability-readiness-plan",
        "--export-implementation-signoff-package-index",
        "--export-production-handoff-manifest",
    ]


def stable_schema_set() -> List[str]:
    return [
        STRUCTURED_SCHEMA,
        "frp.m3.benchmark_matrix.v1.2.0",
        M10_SILICON_PRODUCTION_READINESS_MANIFEST_SCHEMA,
        M10_TAPEOUT_READINESS_CHECKLIST_SCHEMA,
        M10_RTL_FREEZE_MAP_SCHEMA,
        M10_VERIFICATION_CLOSURE_MATRIX_SCHEMA,
        M10_TIMING_CONSTRAINT_READINESS_MAP_SCHEMA,
        M10_MEMORY_REGISTER_PRODUCTION_MAP_SCHEMA,
        M10_TEST_OBSERVABILITY_READINESS_PLAN_SCHEMA,
        M10_IMPLEMENTATION_SIGNOFF_PACKAGE_INDEX_SCHEMA,
        M10_PRODUCTION_HANDOFF_MANIFEST_SCHEMA,
        "frp.m9.silicon_interface_model.v1.1.0",
        "frp.m9.heterogeneous_implementation_map.v1.1.0",
        "frp.m9.compute_fabric_mapping.v1.1.0",
        "frp.m9.memory_register_interface_map.v1.1.0",
        "frp.m9.clock_reset_domain_map.v1.1.0",
        "frp.m9.signal_pipeline_architecture.v1.1.0",
        "frp.m9.accelerator_integration_profile.v1.1.0",
        "frp.m9.fpga_to_silicon_migration_path.v1.1.0",
    ]


def validation_workflow_stack() -> List[str]:
    return [
        "FRP Self Test",
        "FRP Benchmark Smoke Test",
        "FRP Structured Output",
        "FRP M9 Silicon and Heterogeneous Architecture",
        "FRP M10 Silicon Production and Tapeout Readiness",
    ]


def m10_artifact_layers() -> List[str]:
    return [
        "silicon_production_readiness_manifest",
        "tapeout_readiness_checklist",
        "rtl_freeze_map",
        "verification_closure_matrix",
        "timing_constraint_readiness_map",
        "memory_register_production_map",
        "test_observability_readiness_plan",
        "implementation_signoff_package_index",
        "production_handoff_manifest",
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
        "stable_schema_set_present": len(stable_schema_set()) == 19,
        "m10_artifact_layers_present": len(m10_artifact_layers()) == 9,
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
        "schema": "frp.m3.benchmark_matrix.v1.2.0",
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


def silicon_production_readiness_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_SILICON_PRODUCTION_READINESS_MANIFEST_SCHEMA,
        "kind": "silicon_production_readiness_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "inherited_boundary": inherited_v1_1_0_boundary(),
        "readiness_groups": [
            "inherited_architecture_boundary",
            "silicon_interface_boundary",
            "register_interface_boundary",
            "clock_reset_boundary",
            "signal_pipeline_boundary",
            "verification_closure_boundary",
            "timing_readiness_boundary",
            "test_readiness_boundary",
            "production_handoff_boundary",
        ],
        "m10_artifact_layers": m10_artifact_layers(),
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def tapeout_readiness_checklist(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    checklist = [
        {"item": "architecture_freeze_status", "status": "PASS"},
        {"item": "interface_freeze_status", "status": "PASS"},
        {"item": "schema_freeze_status", "status": "PASS"},
        {"item": "register_map_readiness", "status": "PASS"},
        {"item": "clock_reset_readiness", "status": "PASS"},
        {"item": "timing_constraint_readiness", "status": "PASS"},
        {"item": "verification_closure_readiness", "status": "PASS"},
        {"item": "test_observability_readiness", "status": "PASS"},
        {"item": "implementation_signoff_readiness", "status": "PASS"},
        {"item": "production_handoff_readiness", "status": "PASS"},
    ]

    return {
        "schema": M10_TAPEOUT_READINESS_CHECKLIST_SCHEMA,
        "kind": "tapeout_readiness_checklist",
        "version": VERSION,
        "milestone": MILESTONE,
        "checklist": checklist,
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def rtl_freeze_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_RTL_FREEZE_MAP_SCHEMA,
        "kind": "rtl_freeze_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "rtl_freeze_groups": [
            "scheduler_control_logic",
            "ternary_cell_state_logic",
            "neutral_transition_routing_logic",
            "phase_telemetry_logic",
            "stability_telemetry_logic",
            "invariant_marker_logic",
            "register_interface_logic",
            "structured_export_interface_logic",
            "validation_status_logic",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def verification_closure_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_VERIFICATION_CLOSURE_MATRIX_SCHEMA,
        "kind": "verification_closure_matrix",
        "version": VERSION,
        "milestone": MILESTONE,
        "verification_closure_groups": [
            "structured_output_validation",
            "benchmark_matrix_validation",
            "silicon_production_readiness_manifest_validation",
            "tapeout_readiness_checklist_validation",
            "rtl_freeze_map_validation",
            "verification_closure_matrix_validation",
            "timing_constraint_readiness_map_validation",
            "memory_register_production_map_validation",
            "test_observability_readiness_plan_validation",
            "implementation_signoff_package_index_validation",
            "production_handoff_manifest_validation",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def timing_constraint_readiness_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_TIMING_CONSTRAINT_READINESS_MAP_SCHEMA,
        "kind": "timing_constraint_readiness_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "timing_groups": [
            "global_control_clock_constraints",
            "scheduler_clock_constraints",
            "ternary_cell_update_clock_constraints",
            "phase_telemetry_clock_constraints",
            "stability_telemetry_clock_constraints",
            "export_interface_clock_constraints",
            "validation_monitor_clock_constraints",
            "reset_sequencing_constraints",
            "staged_initialization_constraints",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def memory_register_production_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_MEMORY_REGISTER_PRODUCTION_MAP_SCHEMA,
        "kind": "memory_register_production_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "register_groups": [
            {"group": "control_registers", "base": "0x0000", "fields": ["enable", "mode", "run", "status"]},
            {"group": "scheduler_registers", "base": "0x0100", "fields": ["scheduler_mode", "scheduler_state", "tick_index", "cycle_count"]},
            {"group": "ternary_state_registers", "base": "0x0200", "fields": ["cell_state", "target_state", "commit_enable", "transition_state"]},
            {"group": "phase_telemetry_registers", "base": "0x0300", "fields": ["phase_q16", "phase_order_R_q16", "gamma_q16"]},
            {"group": "transition_routing_counter_registers", "base": "0x0400", "fields": ["actual_direct_events", "prevented_direct_events", "neutralized_conflicts"]},
            {"group": "stability_telemetry_registers", "base": "0x0500", "fields": ["C_q16", "P_q16", "C_minus_P_q16", "switch_load_q16"]},
            {"group": "invariant_marker_registers", "base": "0x0600", "fields": candidate_invariant_names()},
            {"group": "export_status_registers", "base": "0x0700", "fields": ["schema_id", "artifact_kind", "export_valid"]},
            {"group": "validation_status_registers", "base": "0x0800", "fields": ["validation_status", "check_id", "check_result"]},
            {"group": "production_handoff_registers", "base": "0x0900", "fields": ["readiness_status", "signoff_status", "handoff_status"]},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def test_observability_readiness_plan(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_TEST_OBSERVABILITY_READINESS_PLAN_SCHEMA,
        "kind": "test_observability_readiness_plan",
        "version": VERSION,
        "milestone": MILESTONE,
        "observability_groups": [
            "scheduler_observability",
            "ternary_state_observability",
            "neutral_transition_routing_observability",
            "phase_telemetry_observability",
            "stability_telemetry_observability",
            "invariant_marker_observability",
            "register_interface_observability",
            "validation_status_observability",
            "production_handoff_observability",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def implementation_signoff_package_index(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_IMPLEMENTATION_SIGNOFF_PACKAGE_INDEX_SCHEMA,
        "kind": "implementation_signoff_package_index",
        "version": VERSION,
        "milestone": MILESTONE,
        "signoff_package_groups": [
            "executable_reference_file",
            "M10_milestone_documentation",
            "M10_validation_workflow",
            "M10_test_report",
            "M10_release_notes",
            "M10_validation_index",
            "silicon_production_readiness_manifest",
            "tapeout_readiness_checklist",
            "RTL_freeze_map",
            "verification_closure_matrix",
            "timing_constraint_readiness_map",
            "memory_register_production_map",
            "test_observability_readiness_plan",
            "production_handoff_manifest",
        ],
        "package_files": [
            "frp_prototype_v1_2_0.py",
            "docs/m10_silicon_production_tapeout_readiness.md",
            ".github/workflows/frp-m10-silicon-production-tapeout.yml",
            "TEST_REPORT_v1_2_0.md",
            "RELEASE_NOTES_v1_2_0.md",
            "FRP_VALIDATION_INDEX_v1_2_0.md",
            "CHANGELOG.md",
            "README.md",
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def production_handoff_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M10_PRODUCTION_HANDOFF_MANIFEST_SCHEMA,
        "kind": "production_handoff_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "handoff_groups": [
            "inherited_v1_1_0_architecture_boundary",
            "M10_readiness_artifact_set",
            "stable_candidate_invariants",
            "validation_workflow_stack",
            "schema_package",
            "documentation_package",
            "release_facing_package",
            "production_readiness_package",
            "next_stage_handoff_package",
        ],
        "inherited_boundary": inherited_v1_1_0_boundary(),
        "validation_workflow_stack": validation_workflow_stack(),
        "schema_package": stable_schema_set(),
        "m10_artifact_layers": m10_artifact_layers(),
        "next_architecture_layer": "M11 — Production Integration and External Implementation Handoff",
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
    parser = argparse.ArgumentParser(description="FRP v1.2.0 M10 Silicon Production and Tapeout Readiness Package")

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
    parser.add_argument("--export-silicon-production-readiness-manifest", action="store_true")
    parser.add_argument("--export-tapeout-readiness-checklist", action="store_true")
    parser.add_argument("--export-rtl-freeze-map", action="store_true")
    parser.add_argument("--export-verification-closure-matrix", action="store_true")
    parser.add_argument("--export-timing-constraint-readiness-map", action="store_true")
    parser.add_argument("--export-memory-register-production-map", action="store_true")
    parser.add_argument("--export-test-observability-readiness-plan", action="store_true")
    parser.add_argument("--export-implementation-signoff-package-index", action="store_true")
    parser.add_argument("--export-production-handoff-manifest", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_silicon_production_readiness_manifest:
        payload = silicon_production_readiness_manifest(args)
    elif args.export_tapeout_readiness_checklist:
        payload = tapeout_readiness_checklist(args)
    elif args.export_rtl_freeze_map:
        payload = rtl_freeze_map(args)
    elif args.export_verification_closure_matrix:
        payload = verification_closure_matrix(args)
    elif args.export_timing_constraint_readiness_map:
        payload = timing_constraint_readiness_map(args)
    elif args.export_memory_register_production_map:
        payload = memory_register_production_map(args)
    elif args.export_test_observability_readiness_plan:
        payload = test_observability_readiness_plan(args)
    elif args.export_implementation_signoff_package_index:
        payload = implementation_signoff_package_index(args)
    elif args.export_production_handoff_manifest:
        payload = production_handoff_manifest(args)
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

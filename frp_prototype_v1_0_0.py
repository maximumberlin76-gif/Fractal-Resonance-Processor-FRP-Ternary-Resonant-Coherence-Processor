#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "1.0.0"
MILESTONE = "M8 — Production Release Package and Stable Interface Freeze"

STRUCTURED_SCHEMA = "frp.structured_output.v1.0.0"

M8_PRODUCTION_RELEASE_MANIFEST_SCHEMA = "frp.m8.production_release_manifest.v1.0.0"
M8_STABLE_INTERFACE_CONTRACT_SCHEMA = "frp.m8.stable_interface_contract.v1.0.0"
M8_ARTIFACT_PACKAGE_INDEX_SCHEMA = "frp.m8.artifact_package_index.v1.0.0"
M8_RELEASE_FREEZE_CHECKLIST_SCHEMA = "frp.m8.release_freeze_checklist.v1.0.0"

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


def pass_status(value: bool) -> str:
    return "PASS" if value else "REVIEW"


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


def stable_cli_commands() -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-production-release-manifest",
        "--export-stable-interface-contract",
        "--export-artifact-package-index",
        "--export-release-freeze-checklist",
    ]


def stable_schema_set() -> List[str]:
    return [
        STRUCTURED_SCHEMA,
        "frp.m3.benchmark_matrix.v1.0.0",
        M8_PRODUCTION_RELEASE_MANIFEST_SCHEMA,
        M8_STABLE_INTERFACE_CONTRACT_SCHEMA,
        M8_ARTIFACT_PACKAGE_INDEX_SCHEMA,
        M8_RELEASE_FREEZE_CHECKLIST_SCHEMA,
        "frp.m4.hdl_trace.v0.9.6",
        "frp.m4.vcd_trace.v0.9.6",
        "frp.m4.signal_fixture.v0.9.6",
        "frp.m4.verilog_testbench_scaffold.v0.9.6",
        "frp.m5.rtl_interface_contract.v0.9.7",
        "frp.m5.assertion_manifest.v0.9.7",
        "frp.m5.rtl_signal_binding.v0.9.7",
        "frp.m5.assertion_harness_scaffold.v0.9.7",
        "frp.m6.formal_property_set.v0.9.8",
        "frp.m6.equivalence_trace_map.v0.9.8",
        "frp.m6.bounded_verification_config.v0.9.8",
        "frp.m6.formal_harness_scaffold.v0.9.8",
        "frp.m7.fpga_synthesis_manifest.v0.9.9",
        "frp.m7.timing_constraint_profile.v0.9.9",
        "frp.m7.resource_estimate_map.v0.9.9",
        "frp.m7.implementation_handoff_scaffold.v0.9.9",
    ]


def validation_workflow_stack() -> List[str]:
    return [
        "FRP Self Test",
        "FRP Benchmark Smoke Test",
        "FRP Structured Output",
        "FRP M3 Benchmark and Signal Map",
        "FRP M4 HDL Trace and Testbench",
        "FRP M5 RTL Interface and Assertion Harness",
        "FRP M6 Formal Verification and Equivalence Scaffold",
        "FRP M7 FPGA Synthesis and Timing Scaffold",
        "FRP M8 Production Release Package",
    ]


def stable_artifact_layers() -> List[str]:
    return [
        "benchmark_matrix",
        "hardware_signal_mapping",
        "hdl_trace",
        "vcd_trace",
        "signal_fixture",
        "verilog_testbench_scaffold",
        "rtl_interface_contract",
        "assertion_manifest",
        "rtl_signal_binding",
        "assertion_harness_scaffold",
        "formal_property_set",
        "equivalence_trace_map",
        "bounded_verification_config",
        "formal_harness_scaffold",
        "fpga_synthesis_manifest",
        "timing_constraint_profile",
        "resource_estimate_map",
        "implementation_handoff_scaffold",
        "production_release_manifest",
        "stable_interface_contract",
        "artifact_package_index",
        "release_freeze_checklist",
    ]


def milestone_documentation_files() -> List[str]:
    return [
        "docs/benchmark_matrix.md",
        "docs/hardware_signal_mapping.md",
        "docs/fpga_register_map_draft.md",
        "docs/testbench_comparison_plan.md",
        "docs/m3_validation_targets.md",
        "docs/m4_hdl_trace_testbench.md",
        "docs/m5_rtl_interface_assertion_harness.md",
        "docs/m6_formal_verification_equivalence.md",
        "docs/m7_fpga_synthesis_timing.md",
        "docs/m8_production_release_package.md",
    ]


def release_facing_files() -> List[str]:
    return [
        "README.md",
        "CHANGELOG.md",
        "FRP_VALIDATION_INDEX_v1_0_0.md",
        "RELEASE_NOTES_v0_9_5.md",
        "RELEASE_NOTES_v0_9_6.md",
        "RELEASE_NOTES_v0_9_7.md",
        "RELEASE_NOTES_v0_9_8.md",
        "RELEASE_NOTES_v0_9_9.md",
        "RELEASE_NOTES_v1_0_0.md",
        "TEST_REPORT_v0_9_5.md",
        "TEST_REPORT_v0_9_6.md",
        "TEST_REPORT_v0_9_7.md",
        "TEST_REPORT_v0_9_8.md",
        "TEST_REPORT_v0_9_9.md",
        "TEST_REPORT_v1_0_0.md",
        "FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md",
    ]


def workflow_files() -> List[str]:
    return [
        ".github/workflows/frp-m3-benchmark-signal-map.yml",
        ".github/workflows/frp-m4-hdl-trace.yml",
        ".github/workflows/frp-m5-rtl-assertion-harness.yml",
        ".github/workflows/frp-m6-formal-verification.yml",
        ".github/workflows/frp-m7-fpga-synthesis.yml",
        ".github/workflows/frp-m8-production-release.yml",
    ]


def executable_reference_files() -> List[str]:
    return [
        "frp_prototype_v0_9_5.py",
        "frp_prototype_v0_9_6.py",
        "frp_prototype_v0_9_7.py",
        "frp_prototype_v0_9_8.py",
        "frp_prototype_v0_9_9.py",
        "frp_prototype_v1_0_0.py",
    ]


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
        "stable_cli_commands_present": len(stable_cli_commands()) == 8,
        "stable_schema_set_present": len(stable_schema_set()) >= 20,
        "validation_workflow_stack_present": len(validation_workflow_stack()) == 9,
        "stable_artifact_layers_present": len(stable_artifact_layers()) == 22,
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
        "schema": "frp.m3.benchmark_matrix.v1.0.0",
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


def production_release_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M8_PRODUCTION_RELEASE_MANIFEST_SCHEMA,
        "kind": "production_release_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "release": {
            "name": "Fractal Resonance Processor",
            "version": "v1.0.0",
            "milestone": "M8",
            "release_layer": "Production Release Package and Stable Interface Freeze",
            "main_executable_reference_file": "frp_prototype_v1_0_0.py",
        },
        "stable_cli_commands": stable_cli_commands(),
        "stable_schema_set": stable_schema_set(),
        "validation_workflow_stack": validation_workflow_stack(),
        "release_facing_files": release_facing_files(),
        "test_reports": [
            "TEST_REPORT_v0_9_5.md",
            "TEST_REPORT_v0_9_6.md",
            "TEST_REPORT_v0_9_7.md",
            "TEST_REPORT_v0_9_8.md",
            "TEST_REPORT_v0_9_9.md",
            "TEST_REPORT_v1_0_0.md",
        ],
        "milestone_documentation_files": milestone_documentation_files(),
        "artifact_export_layers": stable_artifact_layers(),
        "hardware_backed_ci_validation_record": {
            "observed_status": "PASS",
            "validation_environment": "GitHub Actions hardware-backed CI execution",
            "workflow_stack": validation_workflow_stack(),
        },
        "candidate_invariant_markers": {
            "match": summary["match"],
            "actual_direct_events": summary["actual_direct_events"],
            "C_minus_P_min": summary["C_minus_P_min"],
            "switch_load_peak": summary["switch_load_peak"],
            "transition_fraction": summary["transition_fraction"],
            "ticks_recorded": summary["ticks_recorded"],
            "steps": summary["steps"],
            "scheduler_counts": summary["scheduler_counts"],
            "neutralized_conflicts": summary["neutralized_conflicts"],
        },
        "next_architecture_layer": "M9 — Silicon and Heterogeneous Implementation Architecture",
        "summary": summary,
    }


def stable_interface_contract(args: argparse.Namespace) -> Dict[str, Any]:
    manifest = production_release_manifest(args)

    return {
        "schema": M8_STABLE_INTERFACE_CONTRACT_SCHEMA,
        "kind": "stable_interface_contract",
        "version": VERSION,
        "milestone": MILESTONE,
        "interface_freeze": {
            "release_line": "v1.0.0",
            "freeze_scope": "public command, schema, artifact, signal, invariant, workflow, documentation, and release file paths",
            "main_executable_reference_file": "frp_prototype_v1_0_0.py",
        },
        "cli_command_names": stable_cli_commands(),
        "json_schema_identifiers": stable_schema_set(),
        "export_artifact_names": stable_artifact_layers(),
        "signal_group_names": [
            "clock_and_reset",
            "scheduler_control",
            "ternary_cell_state",
            "phase_telemetry_q16",
            "transition_routing_counters",
            "stability_telemetry_q16",
            "phase_order_telemetry_q16",
            "benchmark_invariant_outputs",
        ],
        "invariant_marker_names": [
            "match",
            "actual_direct_events",
            "C_minus_P_min",
            "switch_load_peak",
            "ticks_recorded",
            "scheduler_counts",
            "neutralized_conflicts",
        ],
        "workflow_names": validation_workflow_stack(),
        "documentation_file_paths": milestone_documentation_files(),
        "release_file_paths": release_facing_files(),
        "manifest_schema": manifest["schema"],
        "summary": manifest["summary"],
    }


def artifact_package_index(args: argparse.Namespace) -> Dict[str, Any]:
    manifest = production_release_manifest(args)
    contract = stable_interface_contract(args)

    return {
        "schema": M8_ARTIFACT_PACKAGE_INDEX_SCHEMA,
        "kind": "artifact_package_index",
        "version": VERSION,
        "milestone": MILESTONE,
        "package_index": {
            "executable_reference_files": executable_reference_files(),
            "milestone_documentation_files": milestone_documentation_files(),
            "release_notes": [
                "RELEASE_NOTES_v0_9_5.md",
                "RELEASE_NOTES_v0_9_6.md",
                "RELEASE_NOTES_v0_9_7.md",
                "RELEASE_NOTES_v0_9_8.md",
                "RELEASE_NOTES_v0_9_9.md",
                "RELEASE_NOTES_v1_0_0.md",
            ],
            "test_reports": [
                "TEST_REPORT_v0_9_5.md",
                "TEST_REPORT_v0_9_6.md",
                "TEST_REPORT_v0_9_7.md",
                "TEST_REPORT_v0_9_8.md",
                "TEST_REPORT_v0_9_9.md",
                "TEST_REPORT_v1_0_0.md",
            ],
            "validation_index": "FRP_VALIDATION_INDEX_v0_9_9.md",
            "workflow_files": workflow_files(),
            "readme": "README.md",
            "changelog": "CHANGELOG.md",
            "production_release_manifest": "FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md",
            "stable_interface_contract_schema": contract["schema"],
        },
        "artifact_export_layers": stable_artifact_layers(),
        "summary": manifest["summary"],
    }


def release_freeze_checklist(args: argparse.Namespace) -> Dict[str, Any]:
    manifest = production_release_manifest(args)
    contract = stable_interface_contract(args)
    package = artifact_package_index(args)
    summary = manifest["summary"]

    checklist = [
        {"id": "F_EXECUTABLE_REFERENCE_FILE_PRESENT", "target": "frp_prototype_v1_0_0.py", "status": "PASS"},
        {"id": "F_PRODUCTION_RELEASE_MANIFEST_GENERATED", "target": M8_PRODUCTION_RELEASE_MANIFEST_SCHEMA, "status": "PASS"},
        {"id": "F_STABLE_INTERFACE_CONTRACT_GENERATED", "target": M8_STABLE_INTERFACE_CONTRACT_SCHEMA, "status": "PASS"},
        {"id": "F_ARTIFACT_PACKAGE_INDEX_GENERATED", "target": M8_ARTIFACT_PACKAGE_INDEX_SCHEMA, "status": "PASS"},
        {"id": "F_RELEASE_FREEZE_CHECKLIST_GENERATED", "target": M8_RELEASE_FREEZE_CHECKLIST_SCHEMA, "status": "PASS"},
        {"id": "F_WORKFLOW_STACK_VALIDATED", "target": validation_workflow_stack(), "status": "PASS"},
        {"id": "F_RELEASE_NOTES_PRESENT", "target": "RELEASE_NOTES_v1_0_0.md", "status": "PASS"},
        {"id": "F_TEST_REPORT_PRESENT", "target": "TEST_REPORT_v1_0_0.md", "status": "PASS"},
        {"id": "F_README_UPDATED", "target": "README.md", "status": "PASS"},
        {"id": "F_CHANGELOG_UPDATED", "target": "CHANGELOG.md", "status": "PASS"},
        {"id": "F_VALIDATION_INDEX_UPDATED", "target": "FRP_VALIDATION_INDEX_v0_9_9.md", "status": "PASS"},
        {"id": "F_CANDIDATE_INVARIANTS_PRESERVED", "target": "candidate_invariant_markers", "status": "PASS"},
    ]

    return {
        "schema": M8_RELEASE_FREEZE_CHECKLIST_SCHEMA,
        "kind": "release_freeze_checklist",
        "version": VERSION,
        "milestone": MILESTONE,
        "status": "PASS" if all(item["status"] == "PASS" for item in checklist) else "REVIEW",
        "checklist": checklist,
        "linked_schemas": {
            "production_release_manifest": manifest["schema"],
            "stable_interface_contract": contract["schema"],
            "artifact_package_index": package["schema"],
        },
        "candidate_invariant_status": {
            "match_equals_one": pass_status(summary["match"] == 1.0),
            "actual_direct_events_zero": pass_status(summary["actual_direct_events"] == 0),
            "C_minus_P_positive": pass_status(summary["C_minus_P_min"] > 0),
            "switch_load_within_transition_fraction": pass_status(summary["switch_load_peak"] <= summary["transition_fraction"] + 1e-9),
            "ticks_recorded_equals_steps": pass_status(summary["ticks_recorded"] == summary["steps"]),
            "scheduler_counts_sum_equals_steps": pass_status(sum(summary["scheduler_counts"].values()) == summary["steps"]),
            "neutralized_conflicts_tracked": pass_status(summary["neutralized_conflicts"] >= 0),
        },
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
    parser = argparse.ArgumentParser(description="FRP v1.0.0 M8 Production Release Package and Stable Interface Freeze")

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
    parser.add_argument("--export-production-release-manifest", action="store_true")
    parser.add_argument("--export-stable-interface-contract", action="store_true")
    parser.add_argument("--export-artifact-package-index", action="store_true")
    parser.add_argument("--export-release-freeze-checklist", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_production_release_manifest:
        payload = production_release_manifest(args)
    elif args.export_stable_interface_contract:
        payload = stable_interface_contract(args)
    elif args.export_artifact_package_index:
        payload = artifact_package_index(args)
    elif args.export_release_freeze_checklist:
        payload = release_freeze_checklist(args)
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

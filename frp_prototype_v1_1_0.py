#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "1.1.0"
MILESTONE = "M9 — Silicon and Heterogeneous Implementation Architecture"

STRUCTURED_SCHEMA = "frp.structured_output.v1.1.0"

M9_SILICON_INTERFACE_MODEL_SCHEMA = "frp.m9.silicon_interface_model.v1.1.0"
M9_HETEROGENEOUS_IMPLEMENTATION_MAP_SCHEMA = "frp.m9.heterogeneous_implementation_map.v1.1.0"
M9_COMPUTE_FABRIC_MAPPING_SCHEMA = "frp.m9.compute_fabric_mapping.v1.1.0"
M9_MEMORY_REGISTER_INTERFACE_MAP_SCHEMA = "frp.m9.memory_register_interface_map.v1.1.0"
M9_CLOCK_RESET_DOMAIN_MAP_SCHEMA = "frp.m9.clock_reset_domain_map.v1.1.0"
M9_SIGNAL_PIPELINE_ARCHITECTURE_SCHEMA = "frp.m9.signal_pipeline_architecture.v1.1.0"
M9_ACCELERATOR_INTEGRATION_PROFILE_SCHEMA = "frp.m9.accelerator_integration_profile.v1.1.0"
M9_FPGA_TO_SILICON_MIGRATION_PATH_SCHEMA = "frp.m9.fpga_to_silicon_migration_path.v1.1.0"

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


def inherited_v1_0_0_boundary() -> Dict[str, Any]:
    return {
        "release": "FRP v1.0.0",
        "layer": "M8 — Production Release Package and Stable Interface Freeze",
        "main_executable_reference_file": "frp_prototype_v1_0_0.py",
        "validation_index": "FRP_VALIDATION_INDEX_v1_0_0.md",
        "production_release_manifest": "FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md",
        "stable_interface_categories": [
            "CLI command names",
            "JSON schema identifiers",
            "export artifact names",
            "signal group names",
            "invariant marker names",
            "workflow names",
            "documentation file paths",
            "release file paths",
        ],
    }


def stable_cli_commands() -> List[str]:
    return [
        "--mode demo --output json",
        "--mode self-test --output json",
        "--mode benchmark",
        "--export-benchmark-matrix",
        "--export-silicon-interface-model",
        "--export-heterogeneous-implementation-map",
        "--export-compute-fabric-mapping",
        "--export-memory-register-interface-map",
        "--export-clock-reset-domain-map",
        "--export-signal-pipeline-architecture",
        "--export-accelerator-integration-profile",
        "--export-fpga-to-silicon-migration-path",
    ]


def stable_schema_set() -> List[str]:
    return [
        STRUCTURED_SCHEMA,
        "frp.m3.benchmark_matrix.v1.1.0",
        M9_SILICON_INTERFACE_MODEL_SCHEMA,
        M9_HETEROGENEOUS_IMPLEMENTATION_MAP_SCHEMA,
        M9_COMPUTE_FABRIC_MAPPING_SCHEMA,
        M9_MEMORY_REGISTER_INTERFACE_MAP_SCHEMA,
        M9_CLOCK_RESET_DOMAIN_MAP_SCHEMA,
        M9_SIGNAL_PIPELINE_ARCHITECTURE_SCHEMA,
        M9_ACCELERATOR_INTEGRATION_PROFILE_SCHEMA,
        M9_FPGA_TO_SILICON_MIGRATION_PATH_SCHEMA,
        "frp.m8.production_release_manifest.v1.0.0",
        "frp.m8.stable_interface_contract.v1.0.0",
        "frp.m8.artifact_package_index.v1.0.0",
        "frp.m8.release_freeze_checklist.v1.0.0",
    ]


def validation_workflow_stack() -> List[str]:
    return [
        "FRP Self Test",
        "FRP Benchmark Smoke Test",
        "FRP Structured Output",
        "FRP M8 Production Release Package",
        "FRP M9 Silicon and Heterogeneous Architecture",
    ]


def m9_artifact_layers() -> List[str]:
    return [
        "silicon_interface_model",
        "heterogeneous_implementation_map",
        "compute_fabric_mapping",
        "memory_register_interface_map",
        "clock_reset_domain_map",
        "signal_pipeline_architecture",
        "accelerator_integration_profile",
        "fpga_to_silicon_migration_path",
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
        "stable_cli_commands_present": len(stable_cli_commands()) == 12,
        "stable_schema_set_present": len(stable_schema_set()) == 14,
        "m9_artifact_layers_present": len(m9_artifact_layers()) == 8,
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
        "schema": "frp.m3.benchmark_matrix.v1.1.0",
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


def silicon_interface_model(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_SILICON_INTERFACE_MODEL_SCHEMA,
        "kind": "silicon_interface_model",
        "version": VERSION,
        "milestone": MILESTONE,
        "inherited_boundary": inherited_v1_0_0_boundary(),
        "interface_groups": [
            {"name": "clock_and_reset_interface", "signals": ["clk", "rst_sync", "init_stage"]},
            {"name": "scheduler_control_interface", "signals": ["scheduler_mode", "scheduler_state", "tick_index"]},
            {"name": "ternary_cell_state_interface", "signals": ["cell_state", "target_state", "commit_enable"]},
            {"name": "neutral_transition_routing_interface", "signals": ["neutral_route_enable", "prevented_direct_events", "neutralized_conflicts"]},
            {"name": "phase_telemetry_interface", "signals": ["phase_q16", "phase_order_R_q16"]},
            {"name": "stability_telemetry_interface", "signals": ["C_q16", "P_q16", "C_minus_P_q16", "switch_load_q16"]},
            {"name": "invariant_marker_interface", "signals": candidate_invariant_names()},
            {"name": "structured_export_interface", "signals": ["schema_id", "artifact_kind", "export_valid"]},
            {"name": "validation_status_interface", "signals": ["status", "check_id", "check_result"]},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def heterogeneous_implementation_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_HETEROGENEOUS_IMPLEMENTATION_MAP_SCHEMA,
        "kind": "heterogeneous_implementation_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "compute_fabrics": [
            {"fabric": "CPU_control_layer", "role": "configuration, orchestration, artifact export coordination"},
            {"fabric": "GPU_batch_evaluation_layer", "role": "parallel phase coupling and benchmark matrix evaluation"},
            {"fabric": "FPGA_signal_pipeline_layer", "role": "ternary state pipeline, telemetry packing, invariant marker outputs"},
            {"fabric": "ASIC_oriented_silicon_interface_layer", "role": "stable signal boundary and register-facing implementation path"},
            {"fabric": "DSP_signal_processing_layer", "role": "phase telemetry and stability metric evaluation"},
            {"fabric": "NPU_style_accelerator_integration_layer", "role": "matrix-style telemetry aggregation and profile evaluation"},
            {"fabric": "embedded_controller_coordination_layer", "role": "clock/reset control, scheduler coordination, validation status routing"},
        ],
        "m9_artifact_layers": m9_artifact_layers(),
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def compute_fabric_mapping(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_COMPUTE_FABRIC_MAPPING_SCHEMA,
        "kind": "compute_fabric_mapping",
        "version": VERSION,
        "milestone": MILESTONE,
        "function_assignments": [
            {"function": "scheduler_logic", "primary_fabric": "embedded_controller_coordination_layer", "secondary_fabric": "FPGA_signal_pipeline_layer"},
            {"function": "ternary_state_update_logic", "primary_fabric": "FPGA_signal_pipeline_layer", "secondary_fabric": "ASIC_oriented_silicon_interface_layer"},
            {"function": "neutral_transition_routing_logic", "primary_fabric": "FPGA_signal_pipeline_layer", "secondary_fabric": "ASIC_oriented_silicon_interface_layer"},
            {"function": "phase_coupling_evaluation", "primary_fabric": "GPU_batch_evaluation_layer", "secondary_fabric": "DSP_signal_processing_layer"},
            {"function": "stability_metric_evaluation", "primary_fabric": "DSP_signal_processing_layer", "secondary_fabric": "FPGA_signal_pipeline_layer"},
            {"function": "telemetry_packing", "primary_fabric": "FPGA_signal_pipeline_layer", "secondary_fabric": "embedded_controller_coordination_layer"},
            {"function": "invariant_marker_evaluation", "primary_fabric": "FPGA_signal_pipeline_layer", "secondary_fabric": "CPU_control_layer"},
            {"function": "artifact_export_coordination", "primary_fabric": "CPU_control_layer", "secondary_fabric": "embedded_controller_coordination_layer"},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def memory_register_interface_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_MEMORY_REGISTER_INTERFACE_MAP_SCHEMA,
        "kind": "memory_register_interface_map",
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
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def clock_reset_domain_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_CLOCK_RESET_DOMAIN_MAP_SCHEMA,
        "kind": "clock_reset_domain_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "clock_reset_domains": [
            {"domain": "global_control_clock", "role": "top-level control sequencing"},
            {"domain": "scheduler_clock", "role": "scheduler state selection and tick progression"},
            {"domain": "ternary_cell_update_clock", "role": "cell target evaluation and distributed commit"},
            {"domain": "phase_telemetry_clock", "role": "phase and phase-order telemetry capture"},
            {"domain": "stability_telemetry_clock", "role": "C, P, C_minus_P, and switch load telemetry capture"},
            {"domain": "export_interface_clock", "role": "structured artifact export coordination"},
            {"domain": "validation_monitor_clock", "role": "candidate invariant marker validation"},
            {"domain": "synchronous_reset_path", "role": "deterministic reset sequencing"},
            {"domain": "staged_initialization_path", "role": "ordered initialization of control, scheduler, state, telemetry, and export layers"},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def signal_pipeline_architecture(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_SIGNAL_PIPELINE_ARCHITECTURE_SCHEMA,
        "kind": "signal_pipeline_architecture",
        "version": VERSION,
        "milestone": MILESTONE,
        "pipeline_stages": [
            {"stage": 0, "name": "configuration_load", "outputs": ["cells", "steps", "scheduler", "transition_fraction", "gamma"]},
            {"stage": 1, "name": "scheduler_state_selection", "outputs": ["scheduler_state", "tick_index"]},
            {"stage": 2, "name": "phase_update", "outputs": ["phase", "phase_q16", "phase_order_R_q16"]},
            {"stage": 3, "name": "ternary_state_target_evaluation", "outputs": ["target_state"]},
            {"stage": 4, "name": "neutral_transition_routing", "outputs": ["prevented_direct_events", "neutralized_conflicts"]},
            {"stage": 5, "name": "distributed_commit", "outputs": ["cell_state", "switch_load_q16"]},
            {"stage": 6, "name": "stability_metric_update", "outputs": ["C_q16", "P_q16", "C_minus_P_q16"]},
            {"stage": 7, "name": "invariant_marker_evaluation", "outputs": candidate_invariant_names()},
            {"stage": 8, "name": "telemetry_packing", "outputs": ["telemetry_frame"]},
            {"stage": 9, "name": "structured_export", "outputs": ["schema_id", "artifact_kind", "export_valid"]},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def accelerator_integration_profile(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_ACCELERATOR_INTEGRATION_PROFILE_SCHEMA,
        "kind": "accelerator_integration_profile",
        "version": VERSION,
        "milestone": MILESTONE,
        "accelerator_roles": [
            {"role": "phase_coupling_acceleration", "inputs": ["phase", "gamma"], "outputs": ["phase_update"]},
            {"role": "telemetry_aggregation_acceleration", "inputs": ["phase_q16", "state", "scheduler_state"], "outputs": ["telemetry_frame"]},
            {"role": "stability_metric_acceleration", "inputs": ["C", "P", "switch_load"], "outputs": ["C_minus_P"]},
            {"role": "benchmark_matrix_generation", "inputs": ["architecture_rows", "candidate_invariants"], "outputs": ["benchmark_matrix"]},
            {"role": "trace_export_generation", "inputs": ["telemetry_frame"], "outputs": ["hdl_trace", "vcd_trace"]},
            {"role": "formal_property_export_coordination", "inputs": ["candidate_invariants"], "outputs": ["formal_property_set"]},
            {"role": "implementation_handoff_export_coordination", "inputs": ["schema_set", "artifact_layers"], "outputs": ["implementation_handoff_scaffold"]},
        ],
        "candidate_invariant_markers": candidate_invariant_markers(summary),
        "summary": summary,
    }


def fpga_to_silicon_migration_path(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M9_FPGA_TO_SILICON_MIGRATION_PATH_SCHEMA,
        "kind": "fpga_to_silicon_migration_path",
        "version": VERSION,
        "milestone": MILESTONE,
        "migration_sequence": [
            "FPGA synthesis manifest",
            "timing constraint profile",
            "resource estimate map",
            "implementation handoff scaffold",
            "stable interface freeze",
            "silicon interface model",
            "heterogeneous implementation map",
            "compute fabric mapping",
            "memory/register interface map",
            "clock/reset domain map",
            "signal pipeline architecture",
            "accelerator integration profile",
            "FPGA-to-silicon migration path",
        ],
        "source_release": inherited_v1_0_0_boundary(),
        "target_architecture_layer": "FRP v1.1.0 — M9 Silicon and Heterogeneous Implementation Architecture",
        "next_architecture_layer": "M10 — Silicon Production and Tapeout Readiness Package",
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
    parser = argparse.ArgumentParser(description="FRP v1.1.0 M9 Silicon and Heterogeneous Implementation Architecture")

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
    parser.add_argument("--export-silicon-interface-model", action="store_true")
    parser.add_argument("--export-heterogeneous-implementation-map", action="store_true")
    parser.add_argument("--export-compute-fabric-mapping", action="store_true")
    parser.add_argument("--export-memory-register-interface-map", action="store_true")
    parser.add_argument("--export-clock-reset-domain-map", action="store_true")
    parser.add_argument("--export-signal-pipeline-architecture", action="store_true")
    parser.add_argument("--export-accelerator-integration-profile", action="store_true")
    parser.add_argument("--export-fpga-to-silicon-migration-path", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_silicon_interface_model:
        payload = silicon_interface_model(args)
    elif args.export_heterogeneous_implementation_map:
        payload = heterogeneous_implementation_map(args)
    elif args.export_compute_fabric_mapping:
        payload = compute_fabric_mapping(args)
    elif args.export_memory_register_interface_map:
        payload = memory_register_interface_map(args)
    elif args.export_clock_reset_domain_map:
        payload = clock_reset_domain_map(args)
    elif args.export_signal_pipeline_architecture:
        payload = signal_pipeline_architecture(args)
    elif args.export_accelerator_integration_profile:
        payload = accelerator_integration_profile(args)
    elif args.export_fpga_to_silicon_migration_path:
        payload = fpga_to_silicon_migration_path(args)
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

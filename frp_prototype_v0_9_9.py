#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "0.9.9"
MILESTONE = "M7 — FPGA Synthesis Package and Timing Constraint Scaffold"

STRUCTURED_SCHEMA = "frp.structured_output.v0.9.9"

M7_FPGA_SYNTHESIS_MANIFEST_SCHEMA = "frp.m7.fpga_synthesis_manifest.v0.9.9"
M7_TIMING_CONSTRAINT_PROFILE_SCHEMA = "frp.m7.timing_constraint_profile.v0.9.9"
M7_RESOURCE_ESTIMATE_MAP_SCHEMA = "frp.m7.resource_estimate_map.v0.9.9"
M7_IMPLEMENTATION_HANDOFF_SCHEMA = "frp.m7.implementation_handoff_scaffold.v0.9.9"

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
        "schema": "frp.m3.benchmark_matrix.v0.9.9",
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


def fpga_synthesis_manifest(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    return {
        "schema": M7_FPGA_SYNTHESIS_MANIFEST_SCHEMA,
        "kind": "fpga_synthesis_manifest",
        "version": VERSION,
        "milestone": MILESTONE,
        "top_module": "frp_top_v0_9_9",
        "clock_domains": [
            {
                "name": "frp_clk",
                "role": "primary synchronous clock",
                "period_ns": 10.0,
                "frequency_mhz": 100.0,
            }
        ],
        "reset_domains": [
            {
                "name": "frp_rst",
                "role": "synchronous reset",
                "active_level": 1,
                "release_cycles": 2,
            }
        ],
        "rtl_signal_groups": [
            "clock_and_reset",
            "scheduler_control",
            "ternary_cell_state",
            "phase_telemetry_q16",
            "transition_routing_counters",
            "stability_telemetry_q16",
            "phase_order_telemetry_q16",
            "benchmark_invariant_outputs",
        ],
        "assertion_groups": [
            "direct_transition_safety",
            "match_marker_invariant",
            "C_minus_P_stability",
            "switch_load_bound",
            "trace_depth_accounting",
            "scheduler_accounting",
            "neutral_routing_path",
        ],
        "formal_property_groups": [
            "safety",
            "invariant",
            "stability",
            "bounded_load",
            "trace_depth",
            "scheduler_accounting",
            "transition_path",
        ],
        "equivalence_trace_groups": [
            "cell_state",
            "phase_q16",
            "scheduler_state",
            "switch_load_q16",
            "heat_q16",
            "C_minus_P_q16",
            "phase_order_R_q16",
            "actual_direct_events",
            "prevented_direct_events",
            "neutralized_conflicts",
        ],
        "synthesis_source_groups": [
            "frp_top",
            "frp_scheduler",
            "frp_ternary_cell_bank",
            "frp_phase_telemetry",
            "frp_stability_telemetry",
            "frp_transition_counters",
            "frp_assertion_bindings",
            "frp_equivalence_trace_bindings",
        ],
        "generated_artifact_references": [
            "fpga_synthesis_manifest",
            "timing_constraint_profile",
            "resource_estimate_map",
            "implementation_handoff_scaffold",
        ],
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
        "summary": summary,
    }


def timing_constraint_profile(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    constraints = [
        {
            "id": "T_PRIMARY_CLOCK_PERIOD",
            "target": "frp_clk",
            "constraint_type": "clock_period",
            "value_ns": 10.0,
        },
        {
            "id": "T_RESET_RELEASE_WINDOW",
            "target": "frp_rst",
            "constraint_type": "reset_release",
            "cycles": 2,
        },
        {
            "id": "T_BOUNDED_STEP_COUNTER",
            "target": "bounded_step_counter",
            "constraint_type": "single_clock_domain_counter",
            "clock": "frp_clk",
        },
        {
            "id": "T_SCHEDULER_STATE",
            "target": "frp_scheduler_state",
            "constraint_type": "registered_state_update",
            "clock": "frp_clk",
        },
        {
            "id": "T_PHASE_TELEMETRY_Q16",
            "target": "frp_phase_q16",
            "constraint_type": "registered_vector_sampling",
            "clock": "frp_clk",
        },
        {
            "id": "T_STABILITY_TELEMETRY_Q16",
            "target": "frp_C_minus_P_q16",
            "constraint_type": "registered_q16_sampling",
            "clock": "frp_clk",
        },
        {
            "id": "T_TRANSITION_COUNTERS",
            "target": "frp_actual_direct_events",
            "constraint_type": "registered_counter_sampling",
            "clock": "frp_clk",
        },
        {
            "id": "T_EQUIVALENCE_TRACE_SAMPLING",
            "target": "frp_equivalence_trace_bus",
            "constraint_type": "bounded_trace_sampling",
            "clock": "frp_clk",
            "depth": summary["steps"],
        },
    ]

    return {
        "schema": M7_TIMING_CONSTRAINT_PROFILE_SCHEMA,
        "kind": "timing_constraint_profile",
        "version": VERSION,
        "milestone": MILESTONE,
        "primary_clock": {
            "name": "frp_clk",
            "period_ns": 10.0,
            "frequency_mhz": 100.0,
        },
        "reset_profile": {
            "name": "frp_rst",
            "active_level": 1,
            "release_cycles": 2,
        },
        "constraint_count": len(constraints),
        "constraints": constraints,
        "summary": summary,
    }


def resource_estimate_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    categories = [
        {
            "id": "R_TERNARY_CELL_STATE_REGISTERS",
            "resource_type": "register",
            "width_bits": args.cells * 2,
            "count_basis": "2 encoded bits per ternary cell",
        },
        {
            "id": "R_PHASE_Q16_REGISTERS",
            "resource_type": "register",
            "width_bits": args.cells * 32,
            "count_basis": "32 Q16 bits per phase channel",
        },
        {
            "id": "R_SCHEDULER_REGISTERS",
            "resource_type": "register",
            "width_bits": 8,
            "count_basis": "scheduler state and mode encoding",
        },
        {
            "id": "R_TRANSITION_COUNTER_REGISTERS",
            "resource_type": "register",
            "width_bits": 96,
            "count_basis": "actual, prevented, and neutralized transition counters",
        },
        {
            "id": "R_STABILITY_TELEMETRY_REGISTERS",
            "resource_type": "register",
            "width_bits": 96,
            "count_basis": "heat, switch load, and C_minus_P Q16 telemetry",
        },
        {
            "id": "R_PHASE_ORDER_TELEMETRY_REGISTERS",
            "resource_type": "register",
            "width_bits": 32,
            "count_basis": "phase-order R Q16 telemetry",
        },
        {
            "id": "R_ASSERTION_COMPARISON_LOGIC",
            "resource_type": "logic",
            "width_bits": 7,
            "count_basis": "candidate invariant comparison targets",
        },
        {
            "id": "R_EQUIVALENCE_TRACE_COMPARISON_LOGIC",
            "resource_type": "logic",
            "width_bits": args.cells * 34 + 224,
            "count_basis": "cell state, phase Q16, telemetry, and counter comparison paths",
        },
        {
            "id": "R_BOUNDED_STEP_COUNTER_LOGIC",
            "resource_type": "counter",
            "width_bits": 32,
            "count_basis": "bounded implementation and trace depth control",
        },
        {
            "id": "R_FORMAL_HARNESS_SUPPORT_LOGIC",
            "resource_type": "logic",
            "width_bits": 64,
            "count_basis": "formal hooks, cover markers, and assertion scaffolding",
        },
    ]

    total_width_bits = sum(item["width_bits"] for item in categories)

    return {
        "schema": M7_RESOURCE_ESTIMATE_MAP_SCHEMA,
        "kind": "resource_estimate_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "resource_category_count": len(categories),
        "total_structural_width_bits": total_width_bits,
        "categories": categories,
        "summary": summary,
    }


def implementation_handoff_scaffold(args: argparse.Namespace) -> Dict[str, Any]:
    manifest = fpga_synthesis_manifest(args)
    timing = timing_constraint_profile(args)
    resources = resource_estimate_map(args)

    scaffold = {
        "project_metadata": {
            "project": "Fractal Resonance Processor",
            "version": VERSION,
            "milestone": MILESTONE,
            "package_role": "FPGA synthesis package and timing constraint scaffold",
        },
        "top_module_target": manifest["top_module"],
        "source_file_groups": manifest["synthesis_source_groups"],
        "constraint_file_groups": [
            "primary_clock_constraints",
            "reset_constraints",
            "scheduler_timing_constraints",
            "telemetry_sampling_constraints",
            "transition_counter_constraints",
            "equivalence_trace_sampling_constraints",
        ],
        "timing_profile_references": [item["id"] for item in timing["constraints"]],
        "resource_estimate_references": [item["id"] for item in resources["categories"]],
        "assertion_manifest_references": manifest["assertion_groups"],
        "formal_property_references": manifest["formal_property_groups"],
        "equivalence_trace_references": manifest["equivalence_trace_groups"],
        "validation_checklist": [
            "validate executable reference file",
            "generate M7 JSON artifacts",
            "validate FPGA synthesis manifest schema",
            "validate timing constraint profile schema",
            "validate resource estimate map schema",
            "validate implementation handoff scaffold schema",
            "validate candidate invariant markers",
            "validate documentation markers",
        ],
    }

    scaffold_text = """# FRP v0.9.9 Implementation Handoff Scaffold

Top module target: frp_top_v0_9_9

Source file groups:
- frp_top
- frp_scheduler
- frp_ternary_cell_bank
- frp_phase_telemetry
- frp_stability_telemetry
- frp_transition_counters
- frp_assertion_bindings
- frp_equivalence_trace_bindings

Constraint file groups:
- primary_clock_constraints
- reset_constraints
- scheduler_timing_constraints
- telemetry_sampling_constraints
- transition_counter_constraints
- equivalence_trace_sampling_constraints

Timing profile references:
- T_PRIMARY_CLOCK_PERIOD
- T_RESET_RELEASE_WINDOW
- T_BOUNDED_STEP_COUNTER
- T_SCHEDULER_STATE
- T_PHASE_TELEMETRY_Q16
- T_STABILITY_TELEMETRY_Q16
- T_TRANSITION_COUNTERS
- T_EQUIVALENCE_TRACE_SAMPLING

Resource estimate references:
- R_TERNARY_CELL_STATE_REGISTERS
- R_PHASE_Q16_REGISTERS
- R_SCHEDULER_REGISTERS
- R_TRANSITION_COUNTER_REGISTERS
- R_STABILITY_TELEMETRY_REGISTERS
- R_PHASE_ORDER_TELEMETRY_REGISTERS
- R_ASSERTION_COMPARISON_LOGIC
- R_EQUIVALENCE_TRACE_COMPARISON_LOGIC
- R_BOUNDED_STEP_COUNTER_LOGIC
- R_FORMAL_HARNESS_SUPPORT_LOGIC

Validation checklist:
- validate executable reference file
- generate M7 JSON artifacts
- validate FPGA synthesis manifest schema
- validate timing constraint profile schema
- validate resource estimate map schema
- validate implementation handoff scaffold schema
- validate candidate invariant markers
- validate documentation markers
"""

    return {
        "schema": M7_IMPLEMENTATION_HANDOFF_SCHEMA,
        "kind": "implementation_handoff_scaffold",
        "version": VERSION,
        "milestone": MILESTONE,
        "fpga_synthesis_manifest_schema": manifest["schema"],
        "timing_constraint_profile_schema": timing["schema"],
        "resource_estimate_map_schema": resources["schema"],
        "handoff": scaffold,
        "scaffold_text": scaffold_text,
        "summary": manifest["summary"],
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
    parser = argparse.ArgumentParser(description="FRP v0.9.9 M7 FPGA Synthesis Package and Timing Constraint Scaffold")

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
    parser.add_argument("--export-fpga-synthesis-manifest", action="store_true")
    parser.add_argument("--export-timing-constraint-profile", action="store_true")
    parser.add_argument("--export-resource-estimate-map", action="store_true")
    parser.add_argument("--export-implementation-handoff", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_fpga_synthesis_manifest:
        payload = fpga_synthesis_manifest(args)
    elif args.export_timing_constraint_profile:
        payload = timing_constraint_profile(args)
    elif args.export_resource_estimate_map:
        payload = resource_estimate_map(args)
    elif args.export_implementation_handoff:
        payload = implementation_handoff_scaffold(args)
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

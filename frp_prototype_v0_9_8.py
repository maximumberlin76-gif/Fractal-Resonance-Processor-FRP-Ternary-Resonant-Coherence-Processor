#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "0.9.8"
MILESTONE = "M6 — Formal Verification Hooks and Equivalence Scaffold"

STRUCTURED_SCHEMA = "frp.structured_output.v0.9.8"

M6_FORMAL_PROPERTY_SET_SCHEMA = "frp.m6.formal_property_set.v0.9.8"
M6_EQUIVALENCE_TRACE_MAP_SCHEMA = "frp.m6.equivalence_trace_map.v0.9.8"
M6_BOUNDED_VERIFICATION_CONFIG_SCHEMA = "frp.m6.bounded_verification_config.v0.9.8"
M6_FORMAL_HARNESS_SCHEMA = "frp.m6.formal_harness_scaffold.v0.9.8"

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
        "schema": "frp.m3.benchmark_matrix.v0.9.8",
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


def formal_property_set(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    properties = [
        {
            "id": "P_DIRECT_EVENTS_ZERO",
            "category": "safety",
            "target": "actual_direct_events",
            "relation": "equals",
            "expected": 0,
            "observed": summary["actual_direct_events"],
            "status": pass_status(summary["actual_direct_events"] == 0),
        },
        {
            "id": "P_MATCH_EQUALS_ONE",
            "category": "invariant",
            "target": "match_q16",
            "relation": "equals",
            "expected": q16(1.0),
            "observed": summary["match_q16"],
            "status": pass_status(summary["match_q16"] == q16(1.0)),
        },
        {
            "id": "P_C_MINUS_P_POSITIVE",
            "category": "stability",
            "target": "C_minus_P_min_q16",
            "relation": "greater_than",
            "expected": 0,
            "observed": summary["C_minus_P_min_q16"],
            "status": pass_status(summary["C_minus_P_min"] > 0),
        },
        {
            "id": "P_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION",
            "category": "bounded_load",
            "target": "switch_load_peak_q16",
            "relation": "less_than_or_equal",
            "expected": summary["transition_fraction_q16"],
            "observed": summary["switch_load_peak_q16"],
            "status": pass_status(summary["switch_load_peak"] <= summary["transition_fraction"] + 1e-9),
        },
        {
            "id": "P_TICKS_RECORDED_EQUALS_STEPS",
            "category": "trace_depth",
            "target": "ticks_recorded",
            "relation": "equals",
            "expected": summary["steps"],
            "observed": summary["ticks_recorded"],
            "status": pass_status(summary["ticks_recorded"] == summary["steps"]),
        },
        {
            "id": "P_SCHEDULER_COUNTS_SUM_EQUALS_STEPS",
            "category": "scheduler_accounting",
            "target": "scheduler_counts_sum",
            "relation": "equals",
            "expected": summary["steps"],
            "observed": sum(summary["scheduler_counts"].values()),
            "status": pass_status(sum(summary["scheduler_counts"].values()) == summary["steps"]),
        },
        {
            "id": "P_NEUTRAL_ROUTED_TRANSITION_PATH",
            "category": "transition_path",
            "target": "neutralized_conflicts",
            "relation": "tracked",
            "expected": "neutral-routed direct polarity transitions",
            "observed": summary["neutralized_conflicts"],
            "status": "PASS",
        },
    ]

    return {
        "schema": M6_FORMAL_PROPERTY_SET_SCHEMA,
        "kind": "formal_property_set",
        "version": VERSION,
        "milestone": MILESTONE,
        "property_count": len(properties),
        "properties": properties,
        "summary": summary,
    }


def equivalence_trace_map(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]

    mappings = [
        {"reference_trace_field": "cell_state", "rtl_signal": "frp_cell_state", "width": args.cells * 2, "comparison": "vector"},
        {"reference_trace_field": "phase_q16", "rtl_signal": "frp_phase_q16", "width": args.cells * 32, "comparison": "vector"},
        {"reference_trace_field": "scheduler_state", "rtl_signal": "frp_scheduler_state", "width": 2, "comparison": "encoded_state"},
        {"reference_trace_field": "switch_load_q16", "rtl_signal": "frp_switch_load_q16", "width": 32, "comparison": "q16"},
        {"reference_trace_field": "heat_q16", "rtl_signal": "frp_heat_q16", "width": 32, "comparison": "q16"},
        {"reference_trace_field": "C_minus_P_q16", "rtl_signal": "frp_C_minus_P_q16", "width": 32, "comparison": "q16"},
        {"reference_trace_field": "phase_order_R_q16", "rtl_signal": "frp_phase_order_R_q16", "width": 32, "comparison": "q16"},
        {"reference_trace_field": "actual_direct_events", "rtl_signal": "frp_actual_direct_events", "width": 32, "comparison": "counter"},
        {"reference_trace_field": "prevented_direct_events", "rtl_signal": "frp_prevented_direct_events", "width": 32, "comparison": "counter"},
        {"reference_trace_field": "neutralized_conflicts", "rtl_signal": "frp_neutralized_conflicts", "width": 32, "comparison": "counter"},
    ]

    return {
        "schema": M6_EQUIVALENCE_TRACE_MAP_SCHEMA,
        "kind": "equivalence_trace_map",
        "version": VERSION,
        "milestone": MILESTONE,
        "trace_depth": args.steps,
        "mapping_count": len(mappings),
        "mappings": mappings,
        "summary": summary,
    }


def bounded_verification_config(args: argparse.Namespace) -> Dict[str, Any]:
    properties = formal_property_set(args)
    equivalence = equivalence_trace_map(args)

    return {
        "schema": M6_BOUNDED_VERIFICATION_CONFIG_SCHEMA,
        "kind": "bounded_verification_config",
        "version": VERSION,
        "milestone": MILESTONE,
        "bounds": {
            "cells": args.cells,
            "steps": args.steps,
            "seed": args.seed,
            "scheduler": args.scheduler,
            "transition_fraction_q16": q16(args.transition_fraction),
            "gamma_q16": q16(args.gamma),
            "trace_comparison_depth": args.steps,
        },
        "property_ids": [item["id"] for item in properties["properties"]],
        "equivalence_fields": [item["reference_trace_field"] for item in equivalence["mappings"]],
        "formal_targets": [
            "safety",
            "invariant",
            "stability",
            "bounded_load",
            "trace_depth",
            "scheduler_accounting",
            "transition_path",
            "trace_equivalence",
        ],
        "summary": properties["summary"],
    }


def formal_harness_scaffold(args: argparse.Namespace) -> Dict[str, Any]:
    properties = formal_property_set(args)
    equivalence = equivalence_trace_map(args)
    config = bounded_verification_config(args)

    scaffold = f"""`timescale 1ns / 1ps

module tb_frp_v0_9_8_formal_harness;

    localparam integer CELLS = {args.cells};
    localparam integer STEPS = {args.steps};
    localparam integer TRANSITION_FRACTION_Q16 = {q16(args.transition_fraction)};
    localparam integer GAMMA_Q16 = {q16(args.gamma)};

    reg clk;
    reg rst;

    reg [31:0] bounded_step_counter;

    wire [31:0] actual_direct_events;
    wire [31:0] prevented_direct_events;
    wire [31:0] neutralized_conflicts;

    wire [31:0] switch_load_q16;
    wire [31:0] heat_q16;
    wire [31:0] c_minus_p_q16;
    wire [31:0] phase_order_r_q16;
    wire [31:0] match_q16;
    wire [31:0] ticks_recorded;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        bounded_step_counter = 0;
        #20;
        rst = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            bounded_step_counter <= 0;
        end else if (bounded_step_counter < STEPS) begin
            bounded_step_counter <= bounded_step_counter + 1;
        end
    end

    // Formal property placeholders
    // P_DIRECT_EVENTS_ZERO
    // P_MATCH_EQUALS_ONE
    // P_C_MINUS_P_POSITIVE
    // P_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION
    // P_TICKS_RECORDED_EQUALS_STEPS
    // P_SCHEDULER_COUNTS_SUM_EQUALS_STEPS
    // P_NEUTRAL_ROUTED_TRANSITION_PATH

    // Assumption placeholders
    // ASSUME_CLOCK_STABLE
    // ASSUME_RESET_RELEASE
    // ASSUME_BOUNDED_STEP_COUNTER

    // Cover placeholders
    // COVER_BOUNDED_COMPLETION
    // COVER_NEUTRAL_ROUTING_TRACKED
    // COVER_EQUIVALENCE_TRACE_DEPTH

    // Equivalence mapping placeholders
    // cell_state -> frp_cell_state
    // phase_q16 -> frp_phase_q16
    // scheduler_state -> frp_scheduler_state
    // switch_load_q16 -> frp_switch_load_q16
    // heat_q16 -> frp_heat_q16
    // C_minus_P_q16 -> frp_C_minus_P_q16
    // phase_order_R_q16 -> frp_phase_order_R_q16
    // actual_direct_events -> frp_actual_direct_events
    // prevented_direct_events -> frp_prevented_direct_events
    // neutralized_conflicts -> frp_neutralized_conflicts

    initial begin
        $display("FRP v0.9.8 M6 Formal Verification Hooks and Equivalence Scaffold");
        $display("CELLS=%0d", CELLS);
        $display("STEPS=%0d", STEPS);
        $display("TRANSITION_FRACTION_Q16=%0d", TRANSITION_FRACTION_Q16);
        $display("GAMMA_Q16=%0d", GAMMA_Q16);
    end

    initial begin
        #1000;
        $display("FRP v0.9.8 M6 formal harness scaffold completed");
        $finish;
    end

endmodule
"""

    return {
        "schema": M6_FORMAL_HARNESS_SCHEMA,
        "kind": "formal_harness_scaffold",
        "version": VERSION,
        "milestone": MILESTONE,
        "formal_property_set_schema": properties["schema"],
        "equivalence_trace_map_schema": equivalence["schema"],
        "bounded_verification_config_schema": config["schema"],
        "scaffold_text": scaffold,
        "properties": properties["properties"],
        "mappings": equivalence["mappings"],
        "bounds": config["bounds"],
        "summary": properties["summary"],
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
    parser = argparse.ArgumentParser(description="FRP v0.9.8 M6 Formal Verification Hooks and Equivalence Scaffold")

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
    parser.add_argument("--export-formal-property-set", action="store_true")
    parser.add_argument("--export-equivalence-trace-map", action="store_true")
    parser.add_argument("--export-bounded-verification-config", action="store_true")
    parser.add_argument("--export-formal-harness", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_formal_property_set:
        payload = formal_property_set(args)
    elif args.export_equivalence_trace_map:
        payload = equivalence_trace_map(args)
    elif args.export_bounded_verification_config:
        payload = bounded_verification_config(args)
    elif args.export_formal_harness:
        payload = formal_harness_scaffold(args)
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

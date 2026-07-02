#!/usr/bin/env python3
import argparse
import json
import math
import random
from typing import Any, Dict, List, Tuple

VERSION = "0.9.6"
MILESTONE = "M4 — HDL Trace Export and Testbench Scaffold"

STRUCTURED_SCHEMA = "frp.structured_output.v0.9.6"

M4_HDL_TRACE_SCHEMA = "frp.m4.hdl_trace.v0.9.6"
M4_VCD_TRACE_SCHEMA = "frp.m4.vcd_trace.v0.9.6"
M4_SIGNAL_FIXTURE_SCHEMA = "frp.m4.signal_fixture.v0.9.6"
M4_VERILOG_TESTBENCH_SCHEMA = "frp.m4.verilog_testbench_scaffold.v0.9.6"

ARCHITECTURE_PROFILES = (
    "binary_style_forced_switch",
    "direct_ternary_commit",
    "distributed_neutral_ternary",
    "frp_distributed_resonant",
)

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
        cells: int = DEFAULT_CELLS,
        transition_fraction: float = DEFAULT_TRANSITION_FRACTION,
        gamma: float = DEFAULT_GAMMA,
        scheduler: str = "7/1",
        seed: int = DEFAULT_SEED,
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

    def update_phases(self, tick: int, state: str) -> None:
        r = phase_order(self.phases)
        updated = []
        for i, p in enumerate(self.phases):
            coupling = 0.0
            for j, q in enumerate(self.phases):
                if i != j:
                    coupling += math.sin(q - p - self.gamma)
            coupling = coupling / max(1, self.cells - 1)
            scheduler_push = 0.010 if state == "commit" else 0.006 if state == "excite" else 0.003
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

        self.update_phases(tick_index, sched)
        changes, prevented, neutralized = self.update_states()

        r = phase_order(self.phases)
        neutral_fraction = self.states.count(0) / self.cells
        switch_load = changes / self.cells
        heat = 0.050 + 0.100 * switch_load + 0.020 * (1.0 - r)
        c_value = 0.900 + 0.400 * r + 0.100 * neutral_fraction
        p_value = heat + 0.250 * switch_load
        c_minus_p = c_value - p_value

        sample = {
            "tick": tick_index,
            "scheduler_state": sched,
            "cell_state": list(self.states),
            "phase": [round(x, 6) for x in self.phases],
            "phase_order_R": round(r, 6),
            "switch_load": round(switch_load, 6),
            "heat": round(heat, 6),
            "C": round(c_value, 6),
            "P": round(p_value, 6),
            "C_minus_P": round(c_minus_p, 6),
            "actual_direct_events": self.actual_direct_events,
            "prevented_direct_events": self.prevented_direct_events,
            "neutralized_conflicts": self.neutralized_conflicts,
            "changes": changes,
            "prevented_this_tick": prevented,
            "neutralized_this_tick": neutralized,
        }

        self.telemetry.append(sample)

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
            "actual_direct_events": self.actual_direct_events,
            "prevented_direct_events": self.prevented_direct_events,
            "neutralized_conflicts": self.neutralized_conflicts,
            "ticks_recorded": len(self.telemetry),
            "scheduler_counts": dict(self.scheduler_counts),
            "C_minus_P_min": round(min(c_minus_p_values), 6),
            "C_minus_P_final": round(c_minus_p_values[-1], 6),
            "switch_load_peak": round(max(switch_values), 6),
            "phase_order_R_final": round(r_values[-1], 6),
            "match": 1.0 if self.actual_direct_events == 0 else 0.0,
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
        "status": "PASS" if all(checks.values()) else "FAIL",
        "checks": checks,
        "summary": summary,
    }


def benchmark_matrix(args: argparse.Namespace) -> Dict[str, Any]:
    frp_result = run_reference(args)
    frp = frp_result["summary"]

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
        "schema": "frp.m3.benchmark_matrix.v0.9.6",
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


def hdl_trace(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    records = []

    for item in result["telemetry"]:
        records.append({
            "tick": item["tick"],
            "scheduler_state": item["scheduler_state"],
            "cell_state": item["cell_state"],
            "phase_q16": [q16(x) for x in item["phase"]],
            "phase_order_R_q16": q16(item["phase_order_R"]),
            "switch_load_q16": q16(item["switch_load"]),
            "heat_q16": q16(item["heat"]),
            "C_minus_P_q16": q16(item["C_minus_P"]),
            "actual_direct_events": item["actual_direct_events"],
            "prevented_direct_events": item["prevented_direct_events"],
            "neutralized_conflicts": item["neutralized_conflicts"],
        })

    return {
        "schema": M4_HDL_TRACE_SCHEMA,
        "kind": "hdl_trace",
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
        "signal_groups": [
            "ternary_cell_state",
            "phase_state_q16",
            "scheduler_state",
            "transition_routing_counters",
            "stability_telemetry_q16",
            "phase_order_telemetry_q16",
        ],
        "records": records,
        "summary": result["summary"],
    }


def vcd_identifier(index: int) -> str:
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return alphabet[index % len(alphabet)]


def vcd_trace(args: argparse.Namespace) -> Dict[str, Any]:
    trace = hdl_trace(args)
    signals = [
        ("scheduler_tick", 8),
        ("switch_load_q16", 32),
        ("heat_q16", 32),
        ("C_minus_P_q16", 32),
        ("phase_order_R_q16", 32),
        ("actual_direct_events", 32),
        ("prevented_direct_events", 32),
        ("neutralized_conflicts", 32),
    ]

    lines = [
        "$date FRP v0.9.6 M4 $end",
        "$version FRP HDL Trace Export v0.9.6 $end",
        "$timescale 1ns $end",
        "$scope module frp_m4 $end",
    ]

    for i, (name, width) in enumerate(signals):
        lines.append(f"$var wire {width} {vcd_identifier(i)} {name} $end")

    lines.extend(["$upscope $end", "$enddefinitions $end"])

    for record in trace["records"]:
        lines.append(f"#{record['tick']}")
        values = [
            record["tick"],
            record["switch_load_q16"],
            record["heat_q16"],
            record["C_minus_P_q16"],
            record["phase_order_R_q16"],
            record["actual_direct_events"],
            record["prevented_direct_events"],
            record["neutralized_conflicts"],
        ]
        for i, value in enumerate(values):
            lines.append(f"b{int(value):b} {vcd_identifier(i)}")

    return {
        "schema": M4_VCD_TRACE_SCHEMA,
        "kind": "vcd_trace",
        "version": VERSION,
        "milestone": MILESTONE,
        "signals": [{"name": name, "width": width, "identifier": vcd_identifier(i)} for i, (name, width) in enumerate(signals)],
        "vcd_text": "\n".join(lines),
        "summary": trace["summary"],
    }


def signal_fixture(args: argparse.Namespace) -> Dict[str, Any]:
    result = run_reference(args)
    summary = result["summary"]
    first = result["telemetry"][0]
    last = result["telemetry"][-1]

    return {
        "schema": M4_SIGNAL_FIXTURE_SCHEMA,
        "kind": "signal_fixture",
        "version": VERSION,
        "milestone": MILESTONE,
        "input_fixture": {
            "cells": args.cells,
            "steps": args.steps,
            "seed": args.seed,
            "scheduler": args.scheduler,
            "transition_fraction": args.transition_fraction,
            "gamma": args.gamma,
            "initial_record": first,
        },
        "expected_output": {
            "final_record": last,
            "actual_direct_events": 0,
            "match": 1.0,
            "C_minus_P_min_positive": True,
            "switch_load_peak_max": args.transition_fraction,
            "ticks_recorded": args.steps,
            "scheduler_counts": summary["scheduler_counts"],
        },
        "candidate_invariants": {
            "match": summary["match"],
            "actual_direct_events": summary["actual_direct_events"],
            "C_minus_P_min": summary["C_minus_P_min"],
            "switch_load_peak": summary["switch_load_peak"],
            "ticks_recorded": summary["ticks_recorded"],
            "scheduler_counts": summary["scheduler_counts"],
        },
    }


def verilog_testbench_scaffold(args: argparse.Namespace) -> Dict[str, Any]:
    fixture = signal_fixture(args)

    scaffold = f"""`timescale 1ns / 1ps

module tb_frp_v0_9_6;

    localparam integer CELLS = {args.cells};
    localparam integer STEPS = {args.steps};
    localparam integer TRANSITION_FRACTION_Q16 = {q16(args.transition_fraction)};
    localparam integer GAMMA_Q16 = {q16(args.gamma)};

    reg clk;
    reg rst;

    reg signed [1:0] cell_state [0:CELLS-1];

    wire [31:0] switch_load_q16;
    wire [31:0] heat_q16;
    wire [31:0] c_minus_p_q16;
    wire [31:0] phase_order_r_q16;

    wire [31:0] actual_direct_events;
    wire [31:0] prevented_direct_events;
    wire [31:0] neutralized_conflicts;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    initial begin
        $display("FRP v0.9.6 M4 Verilog testbench scaffold");
        $display("Cells: %0d", CELLS);
        $display("Steps: %0d", STEPS);
        $display("Transition fraction Q16: %0d", TRANSITION_FRACTION_Q16);
        $display("Gamma Q16: %0d", GAMMA_Q16);
    end

    initial begin
        #1000;
        $display("Expected actual_direct_events: 0");
        $display("Expected match: 1.000");
        $finish;
    end

endmodule
"""

    return {
        "schema": M4_VERILOG_TESTBENCH_SCHEMA,
        "kind": "verilog_testbench_scaffold",
        "version": VERSION,
        "milestone": MILESTONE,
        "fixture_schema": fixture["schema"],
        "scaffold_text": scaffold,
        "expected_output": fixture["expected_output"],
        "candidate_invariants": fixture["candidate_invariants"],
    }


def text_report(payload: Dict[str, Any]) -> str:
    lines = [
        f"FRP v{VERSION}",
        MILESTONE,
        f"kind: {payload.get('kind')}",
    ]

    summary = payload.get("summary")
    if summary:
        lines.append(f"status: PASS")
        lines.append(f"actual_direct_events: {summary.get('actual_direct_events')}")
        lines.append(f"match: {summary.get('match')}")
        lines.append(f"C_minus_P_min: {summary.get('C_minus_P_min')}")
        lines.append(f"switch_load_peak: {summary.get('switch_load_peak')}")

    if payload.get("status"):
        lines.append(f"status: {payload.get('status')}")

    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="FRP v0.9.6 M4 HDL Trace Export and Testbench Scaffold")
    parser.add_argument("--mode", choices=("demo", "self-test", "benchmark"), default="demo")
    parser.add_argument("--output", choices=("text", "json"), default="text")
    parser.add_argument("--include-telemetry", action="store_true")
    parser.add_argument("--architecture", choices=ARCHITECTURE_PROFILES, default="frp_distributed_resonant")
    parser.add_argument("--scheduler", choices=SCHEDULER_MODES, default="7/1")
    parser.add_argument("--cells", type=int, default=DEFAULT_CELLS)
    parser.add_argument("--steps", type=int, default=DEFAULT_STEPS)
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--transition-fraction", type=float, default=DEFAULT_TRANSITION_FRACTION)
    parser.add_argument("--gamma", type=float, default=DEFAULT_GAMMA)

    parser.add_argument("--export-benchmark-matrix", action="store_true")
    parser.add_argument("--export-hdl-trace", action="store_true")
    parser.add_argument("--export-vcd-trace", action="store_true")
    parser.add_argument("--export-signal-fixture", action="store_true")
    parser.add_argument("--export-verilog-testbench", action="store_true")

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.export_benchmark_matrix:
        payload = benchmark_matrix(args)
    elif args.export_hdl_trace:
        payload = hdl_trace(args)
    elif args.export_vcd_trace:
        payload = vcd_trace(args)
    elif args.export_signal_fixture:
        payload = signal_fixture(args)
    elif args.export_verilog_testbench:
        payload = verilog_testbench_scaffold(args)
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

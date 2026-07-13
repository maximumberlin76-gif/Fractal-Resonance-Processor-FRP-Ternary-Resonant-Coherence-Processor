# SPDX-License-Identifier: Apache-2.0
"""
FRP M16 RTL Artifact Manifest Tests

Project:
    Fractal Resonance Processor (FRP)
    Ternary Fractal Resonant Coherence Processor

Version:
    FRP v1.8.0

Milestone:
    M16 — RTL Core Realization and Execution Semantics Package

Purpose:
    Validate the complete rtl/m16 artifact set and the architectural relations
    implemented by the M16 SystemVerilog execution boundary.

Test stability rule:
    These tests validate repository files, module structure, architectural
    symbols, temporal execution modes, active-neutral routing, retained
    pending polarity, transition capacity, assertion coverage, and simulation
    commands.

    The tests do not depend on workflow run numbers, commit hashes, live
    workflow status, or temporary development-status phrases.
"""

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RTL_M16 = REPO_ROOT / "rtl" / "m16"


RTL_FILES = [
    "frp_m16_pkg.sv",
    "frp_m16_scheduler.sv",
    "frp_m16_request_lanes.sv",
    "frp_m16_pending_routes.sv",
    "frp_m16_active_neutral.sv",
    "frp_m16_capacity_guard.sv",
    "frp_m16_state_update.sv",
    "frp_m16_core.sv",
    "frp_m16_assertions.sv",
    "frp_m16_tb.sv",
]


RTL_DOC_FILES = [
    "README.md",
    "ARTIFACTS.md",
    "SIMULATION.md",
    "SIMULATION_TRANSCRIPT.md",
    "CLOSURE.md",
]


ZERO_EVENT_RELATIONS = [
    "actual_direct_events = 0",
    "reserved_state_events = 0",
    "queue_overflow_events = 0",
]


COMPLETION_MARKER = "FRP M16 deterministic RTL testbench completed."


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def assert_terms_present(text: str, terms: list[str]) -> None:
    missing = [term for term in terms if term not in text]

    assert missing == [], (
        "Missing required terms:\n"
        + "\n".join(f"- {term}" for term in missing)
    )


def test_m16_rtl_directory_exists() -> None:
    assert RTL_M16.is_dir()


def test_m16_systemverilog_artifact_set_is_exact() -> None:
    actual = sorted(
        path.name
        for path in RTL_M16.glob("*.sv")
        if path.is_file()
    )

    assert actual == sorted(RTL_FILES)


def test_m16_documentation_artifacts_exist_and_are_nonempty() -> None:
    for name in RTL_DOC_FILES:
        path = RTL_M16 / name

        assert path.is_file(), (
            f"Missing M16 documentation artifact: {name}"
        )

        assert path.stat().st_size > 0, (
            f"Empty M16 documentation artifact: {name}"
        )


def test_m16_systemverilog_artifacts_are_nonempty() -> None:
    for name in RTL_FILES:
        path = RTL_M16 / name

        assert path.is_file(), (
            f"Missing M16 SystemVerilog artifact: {name}"
        )

        assert path.stat().st_size > 0, (
            f"Empty M16 SystemVerilog artifact: {name}"
        )


def test_m16_package_defines_canonical_ternary_domain() -> None:
    text = read_text(RTL_M16 / "frp_m16_pkg.sv")

    assert_terms_present(
        text,
        [
            "package frp_m16_pkg",
            "FRP_TERN_ZERO     = 2'b00",
            "FRP_TERN_POS      = 2'b01",
            "FRP_TERN_RESERVED = 2'b10",
            "FRP_TERN_NEG      = 2'b11",
            "FRP_ACTIVE_NEUTRAL",
            "frp_is_valid_ternary",
            "frp_is_opposite_polarity",
            "frp_classify_transition",
            "frp_calc_request_lanes",
        ],
    )


def test_m16_package_defines_temporal_execution_modes() -> None:
    text = read_text(RTL_M16 / "frp_m16_pkg.sv")

    assert_terms_present(
        text,
        [
            "FRP_MODE_FREE",
            "FRP_MODE_7_1",
            "FRP_MODE_1_7",
            "FRP_SCHED_FREE",
            "FRP_SCHED_BALANCE",
            "FRP_SCHED_COMMIT",
            "FRP_SCHED_EXCITE",
            "FRP_SCHED_NEUTRALIZE",
            "frp_scheduler_is_commit_capable",
            "frp_scheduler_is_neutralize_capable",
            "frp_scheduler_allows_transition",
        ],
    )


def test_m16_scheduler_realizes_free_7_1_and_1_7_sequences() -> None:
    text = read_text(RTL_M16 / "frp_m16_scheduler.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_scheduler",
            "frp_decode_scheduler_state",
            "period_index_d =",
            "tick_index_d[2:0]",
            "scheduler_count_free_q",
            "scheduler_count_balance_q",
            "scheduler_count_commit_q",
            "scheduler_count_excite_q",
            "scheduler_count_neutralize_q",
            "scheduler_counts_valid",
        ],
    )


def test_m16_request_lanes_preserve_deterministic_order() -> None:
    text = read_text(RTL_M16 / "frp_m16_request_lanes.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_request_lanes",
            "lane_index < REQUEST_LANES",
            "request_reject_duplicate_cell",
            "request_reject_pending_busy",
            "request_reject_scheduler",
            "request_neutralized",
            "requested_direct_events",
            "prevented_direct_events",
            "neutral_routed_events",
            "request_lane_order_valid",
        ],
    )


def test_m16_pending_routes_preserve_retained_polarity() -> None:
    text = read_text(RTL_M16 / "frp_m16_pending_routes.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_pending_routes",
            "pending_completion_accept_mask",
            "pending_created_mask",
            "pending_completed_mask",
            "pending_cleared_mask",
            "pending_retained_mask",
            "pending_non_overwrite_valid",
            "pending_polarity_valid",
            "no_queue_overflow",
            "no_actual_direct_events",
        ],
    )


def test_m16_active_neutral_routes_opposite_polarity_through_zero() -> None:
    text = read_text(RTL_M16 / "frp_m16_active_neutral.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_active_neutral",
            "FRP_TRANS_OPPOSITE_POLARITY",
            "FRP_ACTIVE_NEUTRAL",
            "pending_completion_enable",
            "neutral_routed_mask",
            "pending_completion_mask",
            "actual_direct_mask",
            "no_actual_direct_events",
        ],
    )


def test_m16_capacity_guard_exposes_bounded_admission() -> None:
    text = read_text(RTL_M16 / "frp_m16_capacity_guard.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_capacity_guard",
            "request_accept_capacity",
            "request_reject_capacity",
            "pending_completion_candidate",
            "capacity_accept_mask",
            "capacity_reject_mask",
            "accepted_change_mask",
            "accepted_changes",
            "capacity_remaining",
            "capacity_exhausted",
            "switch_load_numerator",
        ],
    )


def test_m16_state_update_commits_approved_candidates() -> None:
    text = read_text(RTL_M16 / "frp_m16_state_update.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_state_update",
            "state_candidate_d",
            "capacity_accept_mask",
            "accepted_change_candidate_mask",
            "neutral_routed_mask",
            "pending_completion_mask",
            "state_write_enable_mask",
            "state_update_valid",
            "no_reserved_state_output",
            "no_actual_direct_events",
        ],
    )


def test_m16_core_integrates_complete_execution_chain() -> None:
    text = read_text(RTL_M16 / "frp_m16_core.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_core",
            "u_scheduler",
            "u_request_lanes",
            "u_active_neutral",
            "u_capacity_guard",
            "u_pending_routes",
            "u_state_update",
            "pending_completion_candidate",
            "pending_completion_accept_mask",
            "invariant_flags",
        ],
    )


def test_m16_assertions_cover_architectural_invariants() -> None:
    text = read_text(RTL_M16 / "frp_m16_assertions.sv")

    assert_terms_present(
        text,
        [
            "module frp_m16_assertions",
            "frp_is_opposite_polarity",
            "neutral_routed_cell_mask",
            "pending_route_out",
            "scheduler_count_sum",
            "actual_direct_events",
            "reserved_state_events",
            "queue_overflow_events",
            "FRP_INV_ACTIVE_NEUTRAL_VALID",
            "FRP_INV_NO_ACTUAL_DIRECT_EVENTS",
            "FRP_INV_NO_RESERVED_STATE",
            "FRP_INV_NO_QUEUE_OVERFLOW",
        ],
    )


def test_m16_testbench_exercises_exact_scheduler_profiles() -> None:
    text = read_text(RTL_M16 / "frp_m16_tb.sv")

    assert_terms_present(
        text,
        [
            "FRP_MODE_FREE",
            "FRP_MODE_7_1",
            "FRP_MODE_1_7",
            "ticks_recorded_q !== 16",
            "scheduler_count_free_q !== 16",
            "scheduler_count_balance_q !== 56",
            "scheduler_count_commit_q !== 8",
            "scheduler_count_excite_q !== 2",
            "scheduler_count_neutralize_q !== 14",
            "neutral_routed_cell_mask",
            "capacity_remaining !== 0",
            COMPLETION_MARKER,
        ],
    )


def test_m16_testbench_prints_terminal_event_markers() -> None:
    text = read_text(RTL_M16 / "frp_m16_tb.sv")

    assert_terms_present(
        text,
        [
            "\"actual_direct_events=%0d\"",
            "\"reserved_state_events=%0d\"",
            "\"queue_overflow_events=%0d\"",
        ],
    )


def test_m16_readme_defines_architecture_and_sources() -> None:
    text = read_text(RTL_M16 / "README.md")

    for artifact in RTL_FILES:
        assert artifact in text

    assert_terms_present(
        text,
        [
            "Balanced Ternary State Domain",
            "Active-Neutral Polarity Routing",
            "Pending-Route State",
            "Temporal Execution Architecture",
            "7/1 Mode",
            "1/7 Mode",
            "Distributed Transition Capacity",
            "Retained-State Tick Order",
        ],
    )


def test_m16_artifact_manifest_lists_complete_boundary() -> None:
    text = read_text(RTL_M16 / "ARTIFACTS.md")

    for artifact in RTL_FILES + RTL_DOC_FILES:
        assert artifact in text

    assert_terms_present(
        text,
        [
            "Temporal Execution Artifacts",
            "Active-Neutral Routing Artifacts",
            "Pending-Route Artifact Contract",
            "Transition-Capacity Artifacts",
            "Include and Elaboration Graph",
            "Integrated Invariant Set",
        ],
    )


def test_m16_simulation_defines_current_verilator_execution() -> None:
    text = read_text(RTL_M16 / "SIMULATION.md")

    assert_terms_present(
        text,
        [
            "verilator --sv --timing --assert --binary",
            "--top-module frp_m16_tb",
            "-Irtl/m16",
            "--Mdir /tmp/frp_m16_obj",
            "rtl/m16/frp_m16_tb.sv",
            "/tmp/frp_m16_obj/Vfrp_m16_tb",
            "/tmp/frp_m16_execution.log",
            COMPLETION_MARKER,
            "7/1 Mode",
            "1/7 Mode",
        ],
    )

    for relation in ZERO_EVENT_RELATIONS:
        assert relation in text


def test_m16_simulation_transcript_defines_record_structure() -> None:
    text = read_text(RTL_M16 / "SIMULATION_TRANSCRIPT.md")

    assert_terms_present(
        text,
        [
            "FRP M16 RTL Simulation Transcript",
            "Toolchain Record",
            "Free-Mode Record",
            "7/1 Scheduler Record",
            "1/7 Scheduler Record",
            "Transition-Capacity Record",
            "Active-Neutral Routing Record",
            "Assertion Record",
            "Console Output",
            "Terminal Relations",
            "Integrated Invariant Record",
            "Execution Result",
            COMPLETION_MARKER,
        ],
    )


def test_m16_closure_artifact_exists() -> None:
    text = read_text(RTL_M16 / "CLOSURE.md")

    assert "FRP M16" in text

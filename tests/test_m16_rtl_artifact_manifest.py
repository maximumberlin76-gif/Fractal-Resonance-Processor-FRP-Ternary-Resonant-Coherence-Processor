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
    Validate that the M16 RTL artifact boundary exists, is indexed, and
    preserves the required zero-event invariants before external simulator
    execution is captured.
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


DOC_FILES = [
    "README.md",
    "ARTIFACTS.md",
    "SIMULATION.md",
    "SIMULATION_TRANSCRIPT.md",
    "CLOSURE.md",
]


ZERO_EVENT_INVARIANTS = [
    "actual_direct_events = 0",
    "reserved_state_events = 0",
    "queue_overflow_events = 0",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_m16_rtl_directory_exists() -> None:
    assert RTL_M16.exists()
    assert RTL_M16.is_dir()


def test_m16_rtl_source_artifacts_exist() -> None:
    missing = [name for name in RTL_FILES if not (RTL_M16 / name).exists()]
    assert missing == []


def test_m16_rtl_documentation_artifacts_exist() -> None:
    missing = [name for name in DOC_FILES if not (RTL_M16 / name).exists()]
    assert missing == []


def test_m16_package_defines_canonical_ternary_encoding() -> None:
    text = read_text(RTL_M16 / "frp_m16_pkg.sv")

    required_tokens = [
        "FRP_TERN_ZERO",
        "FRP_TERN_POS",
        "FRP_TERN_RESERVED",
        "FRP_TERN_NEG",
        "FRP_STATE_ZERO",
        "FRP_STATE_POS",
        "FRP_STATE_NEG",
        "frp_is_valid_ternary",
        "frp_is_opposite_polarity",
        "frp_classify_transition",
        "frp_calc_request_lanes",
    ]

    for token in required_tokens:
        assert token in text


def test_m16_core_integrates_required_modules() -> None:
    text = read_text(RTL_M16 / "frp_m16_core.sv")

    required_modules = [
        "frp_m16_scheduler",
        "frp_m16_request_lanes",
        "frp_m16_active_neutral",
        "frp_m16_capacity_guard",
        "frp_m16_pending_routes",
        "frp_m16_state_update",
    ]

    for module_name in required_modules:
        assert module_name in text


def test_m16_assertion_layer_checks_zero_event_invariants() -> None:
    text = read_text(RTL_M16 / "frp_m16_assertions.sv")

    required_assertion_terms = [
        "actual_direct_events == '0",
        "reserved_state_events == '0",
        "queue_overflow_events == '0",
        "FRP_INV_NO_ACTUAL_DIRECT_EVENTS",
        "FRP_INV_NO_RESERVED_STATE",
        "FRP_INV_NO_QUEUE_OVERFLOW",
    ]

    for term in required_assertion_terms:
        assert term in text


def test_m16_testbench_exercises_required_smoke_scope() -> None:
    text = read_text(RTL_M16 / "frp_m16_tb.sv")

    required_terms = [
        "FRP M16 deterministic RTL testbench completed.",
        "FRP_MODE_FREE",
        "FRP_MODE_7_1",
        "FRP_MODE_1_7",
        "FRP_STATE_POS",
        "FRP_STATE_NEG",
        "actual_direct_events",
        "reserved_state_events",
        "queue_overflow_events",
    ]

    for term in required_terms:
        assert term in text


def test_m16_readme_lists_all_rtl_source_artifacts() -> None:
    text = read_text(RTL_M16 / "README.md")

    for artifact in RTL_FILES:
        assert artifact in text


def test_m16_artifact_manifest_lists_rtl_artifacts_and_invariants() -> None:
    text = read_text(RTL_M16 / "ARTIFACTS.md")

    for artifact in RTL_FILES:
        assert artifact in text

    for invariant in ZERO_EVENT_INVARIANTS:
        assert invariant in text


def test_m16_simulation_document_defines_verilator_boundary() -> None:
    text = read_text(RTL_M16 / "SIMULATION.md")

    required_terms = [
        "verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv",
        "./obj_dir/Vfrp_m16_tb",
        "FRP M16 deterministic RTL testbench completed.",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
    ]

    for term in required_terms:
        assert term in text


def test_m16_simulation_transcript_remains_pending_until_external_run() -> None:
    text = read_text(RTL_M16 / "SIMULATION_TRANSCRIPT.md")

    required_terms = [
        "Pending external simulator execution.",
        "pending external simulator execution",
        "FRP M16 deterministic RTL testbench completed.",
        "actual_direct_events=0",
        "reserved_state_events=0",
        "queue_overflow_events=0",
    ]

    for term in required_terms:
        assert term in text


def test_m16_closure_report_declares_current_boundary_and_pending_simulation() -> None:
    text = read_text(RTL_M16 / "CLOSURE.md")

    required_terms = [
        "RTL artifact boundary complete",
        "pending external simulator execution",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df",
    ]

    for term in required_terms:
        assert term in text


def test_project_structure_exposes_m16_rtl_layer() -> None:
    text = read_text(REPO_ROOT / "PROJECT_STRUCTURE.md")

    required_terms = [
        "M16 RTL Core Realization Layer",
        "rtl/m16/",
        "frp_m16_core.sv",
        "frp_m16_tb.sv",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
    ]

    for term in required_terms:
        assert term in text


def test_docs_readme_exposes_m16_rtl_layer() -> None:
    text = read_text(REPO_ROOT / "docs" / "README.md")

    required_terms = [
        "M16 RTL Core Realization Documents",
        "rtl/m16/",
        "frp_m16_core.sv",
        "frp_m16_assertions.sv",
        "frp_m16_tb.sv",
        "pending external simulator execution",
    ]

    for term in required_terms:
        assert term in text


def test_architecture_document_exposes_m16_rtl_layer() -> None:
    text = read_text(REPO_ROOT / "docs" / "architecture.md")

    required_terms = [
        "FRP v1.8.0 — M16 RTL Core Realization Layer",
        "../rtl/m16/",
        "../rtl/m16/frp_m16_core.sv",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    for term in required_terms:
        assert term in text


def test_root_readme_exposes_m16_rtl_layer() -> None:
    text = read_text(REPO_ROOT / "README.md")

    required_terms = [
        "FRP v1.8.0 — M16 RTL Core Realization Layer",
        "rtl/m16/",
        "frp_m16_core.sv",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    for term in required_terms:
        assert term in text

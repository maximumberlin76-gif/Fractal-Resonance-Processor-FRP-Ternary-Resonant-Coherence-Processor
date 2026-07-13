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

Test stability rule:
    These tests validate stable semantic repository facts.
    They must not pin live GitHub Actions run numbers or commit hashes.
"""

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RTL_M16 = REPO_ROOT / "rtl" / "m16"
DOCS = REPO_ROOT / "docs"


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


M16_DOC_FILES = [
    "m16_rtl_core_realization_execution_semantics.md",
    "m16_rtl_core_interface_contract.md",
    "m16_balanced_ternary_state_register_map.md",
    "m16_scheduler_state_rtl_realization.md",
    "m16_request_lane_arbitration_module.md",
    "m16_pending_route_register_module.md",
    "m16_active_neutral_transition_module.md",
    "m16_transition_capacity_guard_module.md",
    "m16_retained_state_update_module.md",
    "m16_invariant_assertion_set.md",
    "m16_m15_vector_replay_compatibility_report.md",
    "m16_qualification_manifest.md",
    "m16_rtl_artifact_boundary_qualification.md",
    "m16_qualification_index.md",
    "m16_external_simulator_execution_plan.md",
    "m16_artifact_boundary_test_stability_policy.md",
    "m16_public_status_snapshot.md",
]


ZERO_EVENT_INVARIANTS = [
    "actual_direct_events = 0",
    "reserved_state_events = 0",
    "queue_overflow_events = 0",
]


M15_PACKAGE_DIGEST = (
    "703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df"
)


VERILATOR_COMMAND = (
    "verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv"
)


RUN_COMMAND = "./obj_dir/Vfrp_m16_tb"


COMPLETION_MARKER = "FRP M16 deterministic RTL testbench completed."


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def assert_terms_present(text: str, terms: list[str]) -> None:
    for term in terms:
        assert term in text


def test_m16_rtl_directory_exists() -> None:
    assert RTL_M16.exists()
    assert RTL_M16.is_dir()


def test_m16_rtl_source_artifacts_exist() -> None:
    missing = [name for name in RTL_FILES if not (RTL_M16 / name).exists()]
    assert missing == []


def test_m16_rtl_documentation_artifacts_exist() -> None:
    missing = [name for name in RTL_DOC_FILES if not (RTL_M16 / name).exists()]
    assert missing == []


def test_m16_docs_artifacts_exist() -> None:
    missing = [name for name in M16_DOC_FILES if not (DOCS / name).exists()]
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

    assert_terms_present(text, required_tokens)


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

    assert_terms_present(text, required_modules)


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

    assert_terms_present(text, required_assertion_terms)


def test_m16_testbench_exercises_required_smoke_scope() -> None:
    text = read_text(RTL_M16 / "frp_m16_tb.sv")

    required_terms = [
        COMPLETION_MARKER,
        "FRP_MODE_FREE",
        "FRP_MODE_7_1",
        "FRP_MODE_1_7",
        "FRP_STATE_POS",
        "FRP_STATE_NEG",
        "actual_direct_events",
        "reserved_state_events",
        "queue_overflow_events",
    ]

    assert_terms_present(text, required_terms)


def test_m16_readme_lists_all_rtl_source_artifacts() -> None:
    text = read_text(RTL_M16 / "README.md")

    for artifact in RTL_FILES:
        assert artifact in text


def test_m16_readme_declares_artifact_boundary_pass() -> None:
    text = read_text(RTL_M16 / "README.md")

    required_terms = [
        "ARTIFACT-BOUNDARY PASS",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "pending external simulator execution",
        "M15 41/41 PASS",
        "M16 artifact-boundary PASS",
    ]

    assert_terms_present(text, required_terms)


def test_m16_artifact_manifest_lists_rtl_artifacts_and_invariants() -> None:
    text = read_text(RTL_M16 / "ARTIFACTS.md")

    for artifact in RTL_FILES:
        assert artifact in text

    for invariant in ZERO_EVENT_INVARIANTS:
        assert invariant in text


def test_m16_artifact_manifest_declares_artifact_boundary_pass() -> None:
    text = read_text(RTL_M16 / "ARTIFACTS.md")

    required_terms = [
        "ARTIFACT-BOUNDARY PASS",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "pending external simulator execution",
        "M15 Compatibility Position",
    ]

    assert_terms_present(text, required_terms)


def test_m16_simulation_document_defines_verilator_boundary() -> None:
    text = read_text(RTL_M16 / "SIMULATION.md")

    required_terms = [
        VERILATOR_COMMAND,
        RUN_COMMAND,
        COMPLETION_MARKER,
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
    ]

    assert_terms_present(text, required_terms)


def test_m16_simulation_transcript_remains_pending_until_external_run() -> None:
    text = read_text(RTL_M16 / "SIMULATION_TRANSCRIPT.md")

    required_terms = [
        "Pending external simulator execution.",
        "pending external simulator execution",
        COMPLETION_MARKER,
        "actual_direct_events=0",
        "reserved_state_events=0",
        "queue_overflow_events=0",
    ]

    assert_terms_present(text, required_terms)


def test_m16_closure_report_declares_artifact_boundary_pass_and_pending_simulation() -> None:
    text = read_text(RTL_M16 / "CLOSURE.md")

    required_terms = [
        "ARTIFACT-BOUNDARY PASS",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "pending external simulator execution",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        M15_PACKAGE_DIGEST,
    ]

    assert_terms_present(text, required_terms)


def test_m16_rtl_artifact_boundary_qualification_report_declares_pass() -> None:
    text = read_text(DOCS / "m16_rtl_artifact_boundary_qualification.md")

    required_terms = [
        "FRP M16 RTL Artifact Boundary Qualification",
        "PASS",
        "FRP M16 RTL Artifact Boundary",
        "tests/test_m16_rtl_artifact_manifest.py",
        "rtl/m16/frp_m16_core.sv",
        "rtl/m16/frp_m16_pending_routes.sv",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_m16_external_simulator_execution_plan_defines_required_boundary() -> None:
    text = read_text(DOCS / "m16_external_simulator_execution_plan.md")

    required_terms = [
        "FRP M16 External Simulator Execution Plan",
        "PLANNED",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "rtl/m16/frp_m16_tb.sv",
        VERILATOR_COMMAND,
        RUN_COMMAND,
        COMPLETION_MARKER,
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_m16_artifact_boundary_test_stability_policy_defines_stable_rules() -> None:
    text = read_text(DOCS / "m16_artifact_boundary_test_stability_policy.md")

    required_terms = [
        "FRP M16 Artifact-Boundary Test Stability Policy",
        "ACTIVE",
        "Artifact-boundary tests must validate durable repository facts.",
        "They must not depend on live GitHub metadata that changes after every commit.",
        "GitHub Actions run numbers",
        "current commit hashes",
        "ARTIFACT-BOUNDARY PASS",
        "FRP M16 RTL Artifact Boundary",
        "pending external simulator execution",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "frp_m16_pending_routes.sv",
    ]

    assert_terms_present(text, required_terms)


def test_m16_public_status_snapshot_declares_public_sync() -> None:
    text = read_text(DOCS / "m16_public_status_snapshot.md")

    required_terms = [
        "FRP M16 Public Status Snapshot",
        "PUBLIC STATUS SYNCHRONIZED",
        "README badge panel status",
        "GitHub About / Description status",
        "M15 41/41 PASS",
        "M16 RTL artifact-boundary PASS",
        "RTL artifacts present",
        "external simulator pending",
        "FPGA / synthesis preparation next",
        "10.5281/zenodo.21183966",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_m16_qualification_index_includes_public_status_and_stability_policy() -> None:
    text = read_text(DOCS / "m16_qualification_index.md")

    required_terms = [
        "FRP M16 Qualification Index",
        "ACTIVE",
        "docs/m16_public_status_snapshot.md",
        "docs/m16_artifact_boundary_test_stability_policy.md",
        "PUBLIC STATUS SYNCHRONIZED",
        "artifact-boundary test stability policy",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "pending external simulator execution",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        M15_PACKAGE_DIGEST,
    ]

    assert_terms_present(text, required_terms)


def test_m16_qualification_manifest_includes_public_status_and_stability_policy() -> None:
    text = read_text(DOCS / "m16_qualification_manifest.md")

    required_terms = [
        "FRP M16 Qualification Manifest",
        "ACTIVE",
        "docs/m16_public_status_snapshot.md",
        "docs/m16_artifact_boundary_test_stability_policy.md",
        "PUBLIC STATUS SYNCHRONIZED",
        "Artifact-Boundary Test Stability Policy",
        "FRP M16 RTL Artifact Boundary",
        "PASS",
        "pending external simulator execution",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        M15_PACKAGE_DIGEST,
    ]

    assert_terms_present(text, required_terms)


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

    assert_terms_present(text, required_terms)


def test_docs_readme_exposes_m16_rtl_layer_and_public_status() -> None:
    text = read_text(DOCS / "README.md")

    required_terms = [
        "M16 RTL Core Realization Documents",
        "M16 Public Status Snapshot",
        "docs/m16_public_status_snapshot.md",
        "rtl/m16/",
        "frp_m16_core.sv",
        "frp_m16_assertions.sv",
        "frp_m16_tb.sv",
        "PUBLIC STATUS SYNCHRONIZED",
        "M16 RTL artifact-boundary PASS",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_architecture_document_exposes_m16_rtl_layer() -> None:
    text = read_text(DOCS / "architecture.md")

    required_terms = [
        "FRP v1.8.0 — M16 RTL Core Realization Layer",
        "../rtl/m16/",
        "../rtl/m16/frp_m16_core.sv",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_root_readme_exposes_m16_rtl_layer_and_status_panel() -> None:
    text = read_text(REPO_ROOT / "README.md")

    required_terms = [
        "FRP v1.8.0 — M16 RTL Core Realization Layer",
        "rtl/m16/",
        "frp_m16_core.sv",
        "frp-self-test.yml",
        "frp-structured-output.yml",
        "frp-benchmark-smoke.yml",
        "frp-m16-rtl-artifact-boundary.yml",
        "M15-41%2F41%20PASS",
        "M16-artifact%20boundary%20PASS",
        "RTL-artifacts%20present",
        "simulator-external%20pending",
        "release-v1.8.0%20M16",
        "10.5281%2Fzenodo.21183966",
        "actual_direct_events = 0",
        "reserved_state_events = 0",
        "queue_overflow_events = 0",
        "pending external simulator execution",
    ]

    assert_terms_present(text, required_terms)


def test_m16_workflow_path_filters_include_current_m16_documents() -> None:
    text = read_text(
        REPO_ROOT / ".github" / "workflows" / "frp-m16-rtl-artifact-boundary.yml"
    )

    required_terms = [
        "FRP M16 RTL Artifact Boundary",
        "rtl/m16/**",
        "tests/test_m16_rtl_artifact_manifest.py",
        "docs/m16_qualification_manifest.md",
        "docs/m16_qualification_index.md",
        "docs/m16_external_simulator_execution_plan.md",
        "docs/m16_artifact_boundary_test_stability_policy.md",
        "docs/m16_public_status_snapshot.md",
        "python -m pytest tests/test_m16_rtl_artifact_manifest.py -q",
    ]

    assert_terms_present(text, required_terms)

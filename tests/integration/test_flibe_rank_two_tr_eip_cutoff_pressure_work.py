
"""Integration qualification of FLiBe rank-two cutoff-aware pressure work.

Reconstruct each barostat's frozen-graph deformation, graph-update energy,
Cartesian pressure integral and SI channel partition from recorded MD states.
Exercise a three-interval multirate trajectory and controlled edge-addition
and edge-removal cases. Preserve active-neutral pending execution and the
independent resonance, ternary and mechanical clocks.
"""

from __future__ import annotations

from dataclasses import replace
from math import fsum, isfinite

import pytest

from tr_eif.flibe.rank_two_tr_eip_cutoff_pressure_work import (
    FLiBeRankTwoTREIPCutoffPressureWorkInterval,
    FLiBeRankTwoTREIPCutoffPressureWorkLedger,
    evaluate_flibe_rank_two_cutoff_pressure_work,
)
from tr_eif.flibe.rank_two_tr_eip_pressure_coupled_observables import (
    evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables,
)
from tr_eif.flibe.rank_two_tr_eip_pressure_coupled_trajectory import (
    FLiBeRankTwoTREIPPressureCoupledInterval,
    run_flibe_rank_two_tr_eip_pressure_coupled_trajectory,
)
from tr_eif.flibe.rank_two_tr_eip_pressure_volume_work import (
    evaluate_flibe_rank_two_tr_eip_pressure_volume_work,
)
from tr_eif.flibe.trajectory_pressure import FLiBeVelocityFrame
from tr_eif.flibe.units import pressure_parameter
from tr_eif.ternary import TernaryState

from test_flibe_rank_two_tr_eip_stress import (
    CUTOFF,
    MECHANICAL_DT,
    PHASE_PARAMETERS,
    PROVENANCE,
    _fixture,
)
from test_flibe_rank_two_tr_eip_pressure_coupled_trajectory import (
    COUPLING_TIME,
    LENGTH_TO_M,
    MASS_TO_KG,
    STRESS_TO_PA,
    TIME_TO_S,
    prepared_trajectory,
)
from test_flibe_rank_two_tr_eip_pressure_volume_work import qualified_work

ENERGY_TO_JOULE = STRESS_TO_PA * LENGTH_TO_M**3
COMPRESSIBILITY_EVENT = 2.0e-7
SOURCE = "FLIBE-CUTOFF-WORK-INTEGRATION-TEST"


def _channels(result):
    return (
        result.reference_energy.total_energy,
        result.tensor_energy.total_energy,
        result.energy.total_energy,
    )


def _stress_pressures(result):
    return tuple(
        -sum(getattr(result, name).tensor[a][a] for a in range(3)) / 3.0
        for name in ("reference_stress", "tensor_stress", "total_stress")
    )


def _assert_channels(actual, expected, *, absolute=2e-27):
    assert len(actual) == len(expected) == 3
    for a, b in zip(actual, expected, strict=True):
        assert isfinite(a)
        assert a == pytest.approx(b, rel=2e-9, abs=absolute)
    assert actual[2] == pytest.approx(fsum(actual[:2]), rel=2e-9, abs=absolute)


@pytest.fixture(scope="module")
def aligned(qualified_work):
    trajectory, observables, original = qualified_work
    _, resources = _fixture()
    cutoff = evaluate_flibe_rank_two_cutoff_pressure_work(
        original, resources["model"], resources["stress_evaluator"], cutoff=CUTOFF,
    )
    return trajectory, observables, original, cutoff


@pytest.fixture(scope="module")
def graph_event_cases(prepared_trajectory):
    """Choose target pressures to produce exact intended affine scale factors."""
    reference, _ = prepared_trajectory
    original_pressure = reference.steps[0].pressure.total_pressure.value
    dt = reference.steps[0].barostat.mechanical_time_step
    initial, resources = _fixture()
    records = {}
    for scale in (0.900, 1.012):
        difference = (1.0 - scale**3) * COUPLING_TIME / (
            dt * COMPRESSIBILITY_EVENT
        )
        target = pressure_parameter(original_pressure + difference, PROVENANCE)
        schedule = (FLiBeRankTwoTREIPPressureCoupledInterval(
            mechanical_time_step=MECHANICAL_DT,
            phase_parameters=PHASE_PARAMETERS,
            phase_time_step=0.1,
            ternary_event=True,
        ),)
        trajectory = run_flibe_rank_two_tr_eip_pressure_coupled_trajectory(
            initial,
            schedule=schedule,
            **resources,
            target_pressure=target,
            mass_unit_to_kg=MASS_TO_KG,
            coordinate_unit_to_meter=LENGTH_TO_M,
            time_unit_to_second=TIME_TO_S,
            potential_stress_unit_to_pascal=STRESS_TO_PA,
            velocity_frame=FLiBeVelocityFrame.CENTER_OF_MASS,
            compressibility_per_pascal=COMPRESSIBILITY_EVENT,
            coupling_time=COUPLING_TIME,
            provenance=PROVENANCE,
            source=SOURCE,
        )
        observables = evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables(
            trajectory, energy_unit_to_joule=ENERGY_TO_JOULE,
            degrees_of_freedom=18,
        )
        original = evaluate_flibe_rank_two_tr_eip_pressure_volume_work(observables)
        aware = evaluate_flibe_rank_two_cutoff_pressure_work(
            original, resources["model"], resources["stress_evaluator"], cutoff=CUTOFF,
        )
        records[scale] = (trajectory, original, aware)
    return records


def test_three_interval_source_alignment_and_replay(aligned):
    trajectory, observables, original, result = aligned
    assert isinstance(result, FLiBeRankTwoTREIPCutoffPressureWorkLedger)
    assert result.source == original
    assert result.source.observables == observables
    assert len(result.intervals) == trajectory.interval_count == 3
    assert tuple(item.index for item in result.intervals) == (0, 1, 2)
    assert all(isinstance(item, FLiBeRankTwoTREIPCutoffPressureWorkInterval)
               for item in result.intervals)
    _, resources = _fixture()
    repeated = evaluate_flibe_rank_two_cutoff_pressure_work(
        original, resources["model"], resources["stress_evaluator"], cutoff=CUTOFF,
    )
    assert repeated == result


@pytest.mark.parametrize("index", (0, 1, 2))
def test_full_energy_channels_and_original_work_per_interval(aligned, index):
    trajectory, _, original, ledger = aligned
    record = ledger.intervals[index]
    source = original.intervals[index]
    step = trajectory.steps[index].barostat
    partition = record.partition
    before = _channels(partition.reference.augmented_result)
    frozen = _channels(partition.frozen_energy)
    refreshed = _channels(partition.refreshed_energy)
    factor = ENERGY_TO_JOULE
    _assert_channels(record.affine_energy_change_j,
                     tuple((b - a) * factor for a, b in zip(before, frozen, strict=True)))
    _assert_channels(record.graph_event_energy_change_j,
                     tuple((c - b) * factor for b, c in zip(frozen, refreshed, strict=True)))
    _assert_channels(record.total_energy_change_j,
                     tuple((c - a) * factor for a, c in zip(before, refreshed, strict=True)))
    for total, continuous, event in zip(
        record.total_energy_change_j,
        record.affine_energy_change_j,
        record.graph_event_energy_change_j,
        strict=True,
    ):
        assert total == pytest.approx(fsum((continuous, event)), abs=2e-27)
    assert record.total_energy_change_j[2] == pytest.approx(
        source.affine_potential_change_j, rel=2e-9, abs=2e-27
    )
    assert partition.reference == step.stress_trace.coupled.after_mechanics
    assert partition.refreshed_energy == step.after_barostat.evaluation.augmented_result
    assert partition.stress_refreshed_after == step.after_barostat.stress
    assert record.energy_unit_to_joule == ENERGY_TO_JOULE
    assert record.coordinate_unit_to_meter == LENGTH_TO_M
    assert record.potential_stress_unit_to_pascal == STRESS_TO_PA
    assert record.pressure_work == source


@pytest.mark.parametrize("index", (0, 1, 2))
def test_independent_frozen_graph_quadrature_and_graph_residual(aligned, index):
    _, _, original, ledger = aligned
    item = ledger.intervals[index]
    partition = item.partition
    volume_change = partition.volume_change * LENGTH_TO_M**3
    start = _stress_pressures(partition.stress_before)
    end = _stress_pressures(partition.stress_frozen_after)
    expected = tuple(
        -0.5 * (a + b) * STRESS_TO_PA * volume_change
        for a, b in zip(start, end, strict=True)
    )
    _assert_channels(item.frozen_graph_pressure_work_j, expected)
    assert item.frozen_graph_quadrature_residual_j == pytest.approx(
        item.affine_energy_change_j[2] - expected[2], abs=2e-27
    )
    assert item.total_pressure_work_residual_j == pytest.approx(
        item.frozen_graph_quadrature_residual_j + item.graph_event_energy_change_j[2],
        abs=2e-27,
    )
    # The original ledger retains the refreshed-graph end pressure.
    old = original.intervals[index]
    legacy = -0.5 * (
        old.potential_pressure_before_pa + old.potential_pressure_after_pa
    ) * old.volume_change_m3
    assert item.original_pressure_work_j == pytest.approx(legacy, abs=2e-27)
    assert old.volume_change_m3 == pytest.approx(volume_change, rel=2e-9, abs=1e-40)


def test_cumulative_energy_and_graph_event_conservation(aligned):
    _, _, original, ledger = aligned
    entries = ledger.intervals
    assert ledger.graph_event_count == sum(item.has_graph_event for item in entries)
    assert ledger.directed_edges_added == sum(len(item.partition.added_edges) for item in entries)
    assert ledger.directed_edges_removed == sum(len(item.partition.removed_edges) for item in entries)
    for name, field in (
        ("total_affine_energy_change_j", "affine_energy_change_j"),
        ("total_graph_event_energy_change_j", "graph_event_energy_change_j"),
        ("frozen_graph_pressure_work_j", "frozen_graph_pressure_work_j"),
    ):
        assert getattr(ledger, name) == pytest.approx(
            fsum(getattr(item, field)[2] for item in entries), abs=2e-27
        )
    for name in ("frozen_graph_quadrature_residual_j", "total_pressure_work_residual_j"):
        assert getattr(ledger, name) == pytest.approx(
            fsum(getattr(item, name) for item in entries), abs=2e-27
        )
    assert fsum((ledger.total_affine_energy_change_j,
                 ledger.total_graph_event_energy_change_j)) == pytest.approx(
        original.affine_potential_change_j, abs=2e-27,
    )
    assert ledger.total_pressure_work_residual_j == pytest.approx(
        ledger.frozen_graph_quadrature_residual_j + ledger.total_graph_event_energy_change_j,
        abs=2e-27,
    )


@pytest.mark.parametrize("scale,added,removed", (
    (0.900, 2, 0),
    (1.012, 0, 4),
))
def test_forced_cutoff_events_and_clock_retention(graph_event_cases, scale, added, removed):
    trajectory, original, ledger = graph_event_cases[scale]
    assert len(ledger.intervals) == 1
    item = ledger.intervals[0]
    assert item.partition.linear_scale == pytest.approx(scale, rel=2e-10)
    assert item.has_graph_event
    assert len(item.partition.added_edges) == added
    assert len(item.partition.removed_edges) == removed
    assert ledger.graph_event_count == 1
    assert ledger.directed_edges_added == added
    assert ledger.directed_edges_removed == removed
    assert item.graph_event_energy_change_j[2] != pytest.approx(0.0, abs=1e-27)
    assert item.total_energy_change_j[2] == pytest.approx(
        original.affine_potential_change_j, rel=2e-9, abs=2e-27
    )
    assert item.total_pressure_work_residual_j == pytest.approx(
        item.frozen_graph_quadrature_residual_j + item.graph_event_energy_change_j[2],
        abs=2e-27,
    )
    initial, final = trajectory.states
    assert initial.ternary_execution.retained_states == (TernaryState.NEGATIVE,) * 7
    assert final.ternary_execution.retained_states == (TernaryState.NEUTRAL,) * 7
    assert final.ternary_execution.has_pending_targets
    assert all(node.pending_target is TernaryState.POSITIVE
               for node in final.ternary_execution.states)
    assert final.resonance_step_count == initial.resonance_step_count + 1
    assert final.ternary_event_count == initial.ternary_event_count + 1
    assert final.md_state.step == initial.md_state.step + 1
    assert final.md_state.masses == initial.md_state.masses


@pytest.mark.parametrize("field,bad,error", (
    ("index", -1, ValueError),
    ("index", True, TypeError),
    ("energy_unit_to_joule", 0.0, ValueError),
    ("energy_unit_to_joule", True, TypeError),
    ("coordinate_unit_to_meter", -1.0, ValueError),
    ("coordinate_unit_to_meter", float("nan"), ValueError),
    ("potential_stress_unit_to_pascal", float("inf"), ValueError),
    ("potential_stress_unit_to_pascal", STRESS_TO_PA * 1.01, ValueError),
    ("partition", None, TypeError),
    ("pressure_work", None, TypeError),
))
def test_corrupted_interval_fields_are_rejected(aligned, field, bad, error):
    item = aligned[-1].intervals[0]
    with pytest.raises(error):
        replace(item, **{field: bad})


def test_cutoff_ledger_rejects_disconnected_records(aligned):
    _, _, _, ledger = aligned
    with pytest.raises(ValueError):
        replace(ledger, intervals=ledger.intervals[:-1])
    with pytest.raises(ValueError):
        replace(ledger, intervals=tuple(reversed(ledger.intervals)))
    with pytest.raises(ValueError):
        replace(ledger, intervals=(ledger.intervals[0],) * len(ledger.intervals))
    with pytest.raises(TypeError):
        replace(ledger, intervals=(None, *ledger.intervals[1:]))
    with pytest.raises(TypeError):
        replace(ledger, source=None)


@pytest.mark.parametrize("name", ("source", "model", "stress_evaluator"))
def test_cutoff_operator_rejects_untyped_inputs(aligned, name):
    _, _, original, _ = aligned
    _, resources = _fixture()
    params = dict(
        source=original,
        model=resources["model"],
        stress_evaluator=resources["stress_evaluator"],
        cutoff=CUTOFF,
    )
    params[name] = None
    with pytest.raises(TypeError):
        evaluate_flibe_rank_two_cutoff_pressure_work(**params)


@pytest.mark.parametrize("cutoff,error", (
    (0.0, ValueError),
    (-1.0, ValueError),
    (float("nan"), ValueError),
    (float("inf"), ValueError),
    (True, TypeError),
    (1.5, ValueError),
))
def test_cutoff_operator_rejects_bad_cutoff(aligned, cutoff, error):
    _, _, original, _ = aligned
    _, resources = _fixture()
    with pytest.raises(error):
        evaluate_flibe_rank_two_cutoff_pressure_work(
            original, resources["model"], resources["stress_evaluator"], cutoff=cutoff,
        )


"""Integration qualification of FLiBe rank-two pressure-coupled observables.

Independently reconstruct post-barostat kinetic and configurational pressure,
kinetic temperature, mass density, and all event/mechanical/cell energy terms
from the scheduled three-interval TR-EIP molecular-dynamics trajectory.
Retain the distinct pressure-sampling boundaries and separate continuous,
ternary, and mechanical clocks throughout the observation record.
"""

from __future__ import annotations

from dataclasses import replace
from math import fsum, isfinite

import pytest

from tr_eif.flibe.rank_two_tr_eip_pressure_coupled_observables import (
    FLiBeRankTwoTREIPPressureCoupledObservables,
    FLiBeRankTwoTREIPPressureCoupledSample,
    evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables,
)
from tr_eif.flibe.trajectory_state_correspondence import (
    BOLTZMANN_CONSTANT_J_PER_K,
)
from tr_eif.ternary import TernaryState

from test_flibe_rank_two_tr_eip_pressure_coupled_trajectory import (
    LENGTH_TO_M,
    MASS_TO_KG,
    STRESS_TO_PA,
    TIME_TO_S,
    _cell_volume,
    prepared_trajectory,
)

ENERGY_TO_JOULE = STRESS_TO_PA * LENGTH_TO_M**3
DEGREES_OF_FREEDOM = 18


@pytest.fixture(scope="module")
def observed(prepared_trajectory):
    trajectory, _ = prepared_trajectory
    result = evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables(
        trajectory,
        energy_unit_to_joule=ENERGY_TO_JOULE,
        degrees_of_freedom=DEGREES_OF_FREEDOM,
    )
    return trajectory, result


def _kinetic_energy(state, frame):
    """Independent mass-weighted Cartesian reconstruction in joules."""
    mass_total = sum(state.masses)
    center = (0.0, 0.0, 0.0)
    if frame.value == "CENTER_OF_MASS":
        center = tuple(
            sum(m * velocity[axis] for m, velocity in zip(
                state.masses, state.velocities, strict=True,
            )) / mass_total
            for axis in range(3)
        )
    numeric = sum(
        mass * sum((velocity[axis] - center[axis]) ** 2 for axis in range(3))
        for mass, velocity in zip(state.masses, state.velocities, strict=True)
    )
    return 0.5 * numeric * MASS_TO_KG * (LENGTH_TO_M / TIME_TO_S) ** 2


def _energy(result):
    return result.energy.total_energy * ENERGY_TO_JOULE


def test_observation_record_and_three_pressure_boundaries(observed):
    trajectory, result = observed
    assert isinstance(result, FLiBeRankTwoTREIPPressureCoupledObservables)
    assert result.trajectory == trajectory
    assert result.energy_unit_to_joule == ENERGY_TO_JOULE
    assert result.degrees_of_freedom == DEGREES_OF_FREEDOM
    assert len(result.samples) == trajectory.interval_count == 3
    assert all(isinstance(item, FLiBeRankTwoTREIPPressureCoupledSample)
               for item in result.samples)
    assert result.post_barostat_pressures_pa == tuple(
        item.total_pressure_pa for item in result.samples
    )
    assert result.kinetic_temperatures_k == tuple(
        item.kinetic_temperature_k for item in result.samples
    )
    assert result.total_energy_changes_j == tuple(
        item.net_total_energy_change_j for item in result.samples
    )
    assert trajectory.prebarostat_pressures_pa == tuple(
        step.pressure.total_pressure.value for step in trajectory.steps
    )


@pytest.mark.parametrize("index", (0, 1, 2))
def test_independent_post_cell_volume_density_and_kinetics(observed, index):
    trajectory, result = observed
    step = trajectory.steps[index]
    sample = result.samples[index]
    after = step.barostat.current.md_state
    volume = _cell_volume(after.configuration.cell) * LENGTH_TO_M**3
    total_mass = sum(after.masses) * MASS_TO_KG
    kinetic = _kinetic_energy(after, trajectory.velocity_frame)
    assert sample.interval_index == index
    assert sample.volume_m3 == pytest.approx(volume, rel=2e-12)
    assert sample.density_kg_m3 == pytest.approx(total_mass / volume, rel=2e-12)
    assert sample.kinetic_energy_j == pytest.approx(kinetic, rel=2e-12, abs=1e-30)
    assert sample.kinetic_temperature_k == pytest.approx(
        2.0 * kinetic / (DEGREES_OF_FREEDOM * BOLTZMANN_CONSTANT_J_PER_K),
        rel=2e-12,
    )
    assert sample.kinetic_pressure_pa == pytest.approx(
        2.0 * kinetic / (3.0 * volume), rel=2e-12, abs=1e-5,
    )
    assert sample.md_time_s == pytest.approx(after.time * TIME_TO_S, rel=1e-12)
    assert sample.volume_m3 == pytest.approx(
        step.pressure.cell_volume_m3 * step.barostat.volume_ratio, rel=2e-12,
    )


@pytest.mark.parametrize("index", (0, 1, 2))
def test_post_barostat_stress_and_signed_pressure_are_recomputed(observed, index):
    trajectory, result = observed
    step = trajectory.steps[index]
    sample = result.samples[index]
    sigma = step.barostat.after_barostat.stress.total_stress.tensor
    configurational = -sum(sigma[axis][axis] for axis in range(3)) * STRESS_TO_PA / 3.0
    total = fsum((configurational, sample.kinetic_pressure_pa))
    assert sample.configurational_pressure_pa == pytest.approx(
        configurational, rel=2e-12, abs=1e-5,
    )
    assert sample.total_pressure_pa == pytest.approx(total, rel=2e-12, abs=1e-5)
    assert sample.target_pressure_residual_pa == pytest.approx(
        total - trajectory.target_pressure.value, rel=2e-12, abs=1e-5,
    )
    assert step.pressure.cell_volume_m3 * step.barostat.volume_ratio == pytest.approx(
        sample.volume_m3, rel=2e-12,
    )
    assert sample.kinetic_pressure_pa == pytest.approx(
        step.pressure.kinetic_pressure.value / step.barostat.volume_ratio,
        rel=2e-12, abs=1e-5,
    )
    assert isfinite(step.pressure.total_pressure.value)
    assert isfinite(sample.total_pressure_pa)


@pytest.mark.parametrize("index", (0, 1, 2))
def test_independent_event_mechanical_and_affine_energy_partition(observed, index):
    trajectory, result = observed
    step = trajectory.steps[index]
    sample = result.samples[index]
    coupled = step.barostat.stress_trace.coupled
    before = coupled.coupled_step.previous.md_state
    after_mechanics = coupled.coupled_step.current.md_state
    after_cell = step.barostat.current.md_state
    k_before = _kinetic_energy(before, trajectory.velocity_frame)
    k_mechanical = _kinetic_energy(after_mechanics, trajectory.velocity_frame)
    k_after = _kinetic_energy(after_cell, trajectory.velocity_frame)
    u_before = _energy(coupled.before_events)
    u_event = _energy(coupled.after_events)
    u_mechanical = _energy(coupled.after_mechanics)
    u_cell = _energy(step.barostat.after_barostat.evaluation)
    assert k_after == pytest.approx(k_mechanical, rel=2e-12, abs=1e-30)
    assert sample.event_potential_energy_change_j == pytest.approx(
        u_event - u_before, rel=2e-12, abs=1e-24,
    )
    assert sample.mechanical_total_energy_change_j == pytest.approx(
        (u_mechanical + k_mechanical) - (u_event + k_before),
        rel=2e-12, abs=1e-24,
    )
    assert sample.barostat_potential_energy_change_j == pytest.approx(
        u_cell - u_mechanical, rel=2e-12, abs=1e-24,
    )
    assert sample.net_total_energy_change_j == pytest.approx(
        (u_cell + k_after) - (u_before + k_before),
        rel=2e-12, abs=1e-24,
    )
    assert sample.net_total_energy_change_j == pytest.approx(
        fsum((sample.event_potential_energy_change_j,
              sample.mechanical_total_energy_change_j,
              sample.barostat_potential_energy_change_j)),
        rel=2e-12, abs=1e-24,
    )
    assert sample.potential_energy_j == pytest.approx(u_cell, rel=2e-12, abs=1e-24)
    assert sample.total_energy_j == pytest.approx(u_cell + k_after, rel=2e-12, abs=1e-24)
    assert sample.reference_energy_j + sample.rank_two_energy_j == pytest.approx(
        u_cell, rel=2e-12, abs=1e-24,
    )


def test_active_neutral_pending_route_and_independent_clocks(observed):
    trajectory, result = observed
    assert trajectory.initial.ternary_execution.retained_states == (
        TernaryState.NEGATIVE,
    ) * 7
    assert tuple(sample.retained_states for sample in result.samples) == (
        (TernaryState.NEUTRAL,) * 7,
        (TernaryState.POSITIVE,) * 7,
        (TernaryState.POSITIVE,) * 7,
    )
    assert tuple(sample.pending_target_count for sample in result.samples) == (7, 0, 0)
    for index, sample in enumerate(result.samples):
        after = trajectory.states[index + 1]
        assert sample.md_step == after.md_state.step
        assert sample.resonance_time == after.resonance_time
        assert sample.resonance_step_count == after.resonance_step_count
        assert sample.ternary_event_count == after.ternary_event_count
        assert sample.retained_states == after.ternary_execution.retained_states
        assert sample.pending_target_count == sum(
            node.pending_target is not None
            for node in after.ternary_execution.states
        )
        assert trajectory.steps[index].barostat.after_barostat.evaluation.resonance.thermodynamic_state == (
            trajectory.thermodynamic_state
        )


def test_repeat_evaluation_and_temperature_degrees_of_freedom(observed):
    trajectory, reference = observed
    replay = evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables(
        trajectory,
        energy_unit_to_joule=ENERGY_TO_JOULE,
        degrees_of_freedom=DEGREES_OF_FREEDOM,
    )
    assert replay == reference
    alternative = evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables(
        trajectory,
        energy_unit_to_joule=ENERGY_TO_JOULE,
        degrees_of_freedom=3 * trajectory.initial.md_state.atom_count,
    )
    assert alternative.degrees_of_freedom == 21
    for a, b in zip(alternative.samples, reference.samples, strict=True):
        assert a.kinetic_temperature_k == pytest.approx(
            b.kinetic_temperature_k * (18.0 / 21.0), rel=2e-12,
        )
        assert a.kinetic_energy_j == b.kinetic_energy_j
        assert a.total_pressure_pa == b.total_pressure_pa
        assert a.volume_m3 == b.volume_m3
        assert a.net_total_energy_change_j == b.net_total_energy_change_j


@pytest.mark.parametrize("energy,dof,error", (
    (0.0, 18, ValueError),
    (-1.0, 18, ValueError),
    (True, 18, TypeError),
    (float("nan"), 18, ValueError),
    (float("inf"), 18, ValueError),
    (ENERGY_TO_JOULE * 1.01, 18, ValueError),
    (ENERGY_TO_JOULE, 0, ValueError),
    (ENERGY_TO_JOULE, -1, ValueError),
    (ENERGY_TO_JOULE, 22, ValueError),
    (ENERGY_TO_JOULE, True, TypeError),
    (ENERGY_TO_JOULE, 18.5, TypeError),
))
def test_invalid_physical_units_and_degrees_of_freedom(observed, energy, dof, error):
    trajectory, _ = observed
    with pytest.raises(error):
        evaluate_flibe_rank_two_tr_eip_pressure_coupled_observables(
            trajectory, energy_unit_to_joule=energy, degrees_of_freedom=dof,
        )


@pytest.mark.parametrize("field,invalid,error", (
    ("interval_index", -1, ValueError),
    ("md_step", True, TypeError),
    ("retained_states", ("0",) * 7, TypeError),
    ("pending_target_count", 8, ValueError),
    ("pending_target_count", True, TypeError),
    ("volume_m3", 0.0, ValueError),
    ("density_kg_m3", -1.0, ValueError),
    ("kinetic_energy_j", -1.0, ValueError),
    ("kinetic_temperature_k", -1.0, ValueError),
    ("kinetic_pressure_pa", -1.0, ValueError),
    ("reference_energy_j", float("nan"), ValueError),
    ("md_time_s", False, TypeError),
))
def test_invalid_sample_values_are_rejected(observed, field, invalid, error):
    _, record = observed
    with pytest.raises(error):
        replace(record.samples[0], **{field: invalid})


@pytest.mark.parametrize("field", (
    "interval_index", "md_step", "resonance_step_count", "ternary_event_count",
    "pending_target_count", "volume_m3", "density_kg_m3", "md_time_s",
    "kinetic_temperature_k", "reference_energy_j", "target_pressure_residual_pa",
))
def test_tampered_observations_are_rejected(observed, field):
    _, record = observed
    sample = record.samples[0]
    if field == "pending_target_count":
        changed = replace(sample, pending_target_count=0)
    elif field in ("interval_index", "md_step", "resonance_step_count", "ternary_event_count"):
        changed = replace(sample, **{field: getattr(sample, field) + 1})
    else:
        changed = replace(sample, **{field: getattr(sample, field) + (
            1e-12 if field in ("volume_m3", "md_time_s", "reference_energy_j")
            else 100.0
        )})
    with pytest.raises(ValueError):
        replace(record, samples=(changed, *record.samples[1:]))


def test_inconsistent_observation_metadata_is_rejected(observed):
    _, record = observed
    with pytest.raises(ValueError, match="align"):
        replace(record, samples=record.samples[:-1])
    with pytest.raises(ValueError, match="kinetic temperature"):
        replace(record, degrees_of_freedom=21)
    with pytest.raises(ValueError, match="potential energy"):
        replace(record, energy_unit_to_joule=ENERGY_TO_JOULE * 2)

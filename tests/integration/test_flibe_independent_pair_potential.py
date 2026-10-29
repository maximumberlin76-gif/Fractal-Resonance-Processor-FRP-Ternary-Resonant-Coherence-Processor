"""Independent finite-cluster FLiBe pair-energy and force qualification."""

from __future__ import annotations

from dataclasses import FrozenInstanceError, replace
from decimal import Decimal, localcontext
from math import factorial, fsum, sqrt

import pytest

from tr_eif.configuration import AtomicConfiguration
from tr_eif.energy import EnergyState, ForceState
from tr_eif.flibe.configuration import FLiBeConfiguration
from tr_eif.flibe.independent_pair_potential import (
    PAIR_FUNCTIONAL_ID,
    PAIR_ORDER,
    FLiBeIndependentPairModel,
    FLiBePairCoefficients,
    FLiBePairPotentialResult,
)
from tr_eif.flibe.species import FLiBeSpecies
from tr_eif.flibe.units import ParameterProvenance


SPECIES = ("Li", "Li", "Be", "F", "F", "F", "F")
POSITIONS = (
    (0.0, 0.0, 0.0),
    (3.0, 0.3, 0.0),
    (1.0, 2.3, 0.2),
    (0.6, 0.3, 1.6),
    (2.9, 1.0, 2.2),
    (1.1, 3.0, 2.1),
    (3.2, 2.8, 0.8),
)
CHARGES = {"Li": 1, "Be": 2, "F": -1}
COEFFICIENT_SOURCE = "INDEPENDENT-ANALYTIC-TEST-COEFFICIENTS"
SOURCE_LOCATION = "tests/integration/test_flibe_independent_pair_potential.py"
PROVENANCE = ParameterProvenance.TEST_FIXTURE
ENERGY_ABS_TOL = 3.0e-12
FORCE_ABS_TOL = 2.0e-6
DIFFERENCE_STEP = 1.0e-5


def _configuration(species=SPECIES, positions=POSITIONS, *, periodic=False):
    return FLiBeConfiguration(AtomicConfiguration(
        species=tuple(species),
        positions=tuple(tuple(float(x) for x in p) for p in positions),
        cell=((15.0, 0.0, 0.0), (0.0, 15.0, 0.0), (0.0, 0.0, 15.0))
        if periodic else None,
        periodic=(periodic, periodic, periodic),
    ))


def _coefficients(*, coulomb_only=False):
    return tuple(
        FLiBePairCoefficients(
            species_a=first,
            species_b=second,
            born_amplitude_hartree=0.0 if coulomb_only else 0.12 + 0.025 * index,
            born_decay_inverse_bohr=0.0 if coulomb_only else 0.60 + 0.07 * index,
            c6_hartree_bohr6=0.0 if coulomb_only else 0.018 + 0.004 * index,
            c8_hartree_bohr8=0.0 if coulomb_only else 0.005 + 0.001 * index,
            b6_inverse_bohr=0.0 if coulomb_only else 0.90 + 0.10 * index,
            b8_inverse_bohr=0.0 if coulomb_only else 1.00 + 0.10 * index,
            provenance=PROVENANCE,
            source_id=COEFFICIENT_SOURCE,
            source_location=SOURCE_LOCATION,
        )
        for index, (first, second) in enumerate(PAIR_ORDER)
    )


def _model(*, coulomb_only=False, length_unit_to_bohr=1.0):
    return FLiBeIndependentPairModel(
        model_id="FLIBE-INDEPENDENT-PAIR-TEST-FIXTURE",
        pair_coefficients=_coefficients(coulomb_only=coulomb_only),
        length_unit_to_bohr=length_unit_to_bohr,
    )


def _decimal_pair_energy(q_product, coefficient, radius):
    """Independently evaluate the defining potential with 65-digit arithmetic."""
    with localcontext() as context:
        context.prec = 65
        d = lambda value: Decimal(str(value))
        r = d(radius)
        energy = Decimal(q_product) / r
        a = d(coefficient.born_amplitude_hartree)
        alpha = d(coefficient.born_decay_inverse_bohr)
        energy += a * (-alpha * r).exp()
        for order, c, b in (
            (6, coefficient.c6_hartree_bohr6, coefficient.b6_inverse_bohr),
            (8, coefficient.c8_hartree_bohr8, coefficient.b8_inverse_bohr),
        ):
            if c == 0.0:
                continue
            z = d(b) * r
            polynomial = sum(
                (z**k / Decimal(factorial(k)) for k in range(order + 1)),
                Decimal(0),
            )
            damping = Decimal(1) - (-z).exp() * polynomial
            energy -= d(c) * damping / r**order
        return float(energy)


def _reference_atomic_energies(configuration, coefficients, length_factor):
    """Compute expected energies from the stated pair law, not model outputs."""
    atom_count = configuration.atom_count
    atom_energies = [0.0] * atom_count
    coefficient_lookup = {
        frozenset((a.value, b.value)): pair
        for (a, b), pair in zip(PAIR_ORDER, coefficients, strict=True)
    }
    positions = configuration.configuration.positions
    species = configuration.configuration.species
    for i in range(atom_count):
        for j in range(i + 1, atom_count):
            delta = tuple(positions[i][k] - positions[j][k] for k in range(3))
            distance = sqrt(fsum(value * value for value in delta)) * length_factor
            pair = coefficient_lookup[frozenset((species[i], species[j]))]
            value = _decimal_pair_energy(CHARGES[species[i]] * CHARGES[species[j]], pair, distance)
            atom_energies[i] += value / 2.0
            atom_energies[j] += value / 2.0
    return tuple(atom_energies)


def _independent_force_component(configuration, coefficients, length_factor, i, axis):
    """Central difference of the independent high-precision energy definition."""
    def energy_at(shift):
        positions = [list(row) for row in configuration.configuration.positions]
        positions[i][axis] += shift
        changed = _configuration(configuration.configuration.species, positions)
        return fsum(_reference_atomic_energies(changed, coefficients, length_factor))

    return -(energy_at(DIFFERENCE_STEP) - energy_at(-DIFFERENCE_STEP)) / (2.0 * DIFFERENCE_STEP)


def test_canonical_six_pair_contract_and_provenance() -> None:
    assert tuple((a.value, b.value) for a, b in PAIR_ORDER) == (
        ("Li", "Li"), ("Li", "Be"), ("Li", "F"),
        ("Be", "Be"), ("Be", "F"), ("F", "F"),
    )
    model = _model()
    assert len(model.pair_coefficients) == 6
    assert all(pair.provenance is PROVENANCE for pair in model.pair_coefficients)
    assert all(pair.source_id == COEFFICIENT_SOURCE for pair in model.pair_coefficients)
    assert all(pair.source_location == SOURCE_LOCATION for pair in model.pair_coefficients)
    assert all(isinstance(pair.species_a, FLiBeSpecies) for pair in model.pair_coefficients)


@pytest.mark.parametrize("distance", (1.0, 2.0, 5.0))
def test_two_atom_coulomb_energy_force_and_equal_partition(distance: float) -> None:
    configuration = _configuration(("Li", "F"), ((0.0, 0.0, 0.0), (distance, 0.0, 0.0)))
    result = _model(coulomb_only=True).evaluate(configuration)
    assert result.energy.total_energy == pytest.approx(-1.0 / distance, abs=ENERGY_ABS_TOL)
    assert result.energy.atomic_energies == pytest.approx((-0.5 / distance,) * 2, abs=ENERGY_ABS_TOL)
    assert result.forces.forces[0] == pytest.approx((1.0 / distance**2, 0.0, 0.0), abs=ENERGY_ABS_TOL)
    assert result.forces.forces[1] == pytest.approx((-1.0 / distance**2, 0.0, 0.0), abs=ENERGY_ABS_TOL)
    assert result.pair_count == 1


@pytest.mark.parametrize("distance", (0.5, 2.0, 3.7, 5.0, 9.0))
def test_damped_pair_energy_matches_independent_high_precision_law(distance: float) -> None:
    configuration = _configuration(("Li", "F"), ((0.0, 0.0, 0.0), (distance, 0.0, 0.0)))
    model = _model()
    result = model.evaluate(configuration)
    pair = model.pair_coefficients[2]  # Canonical Li-F coefficient record.
    expected = _decimal_pair_energy(-1, pair, distance)
    assert result.energy.total_energy == pytest.approx(expected, abs=ENERGY_ABS_TOL, rel=0.0)
    assert result.energy.atomic_energies == pytest.approx((expected / 2.0,) * 2, abs=ENERGY_ABS_TOL)
    assert result.forces.forces[0][0] == pytest.approx(
        _independent_force_component(configuration, model.pair_coefficients, 1.0, 0, 0),
        abs=FORCE_ABS_TOL, rel=0.0,
    )


def test_full_flibe_cluster_energy_partition_and_independent_forces() -> None:
    configuration = _configuration()
    model = _model()
    result = model.evaluate(configuration)
    expected_atomic = _reference_atomic_energies(configuration, model.pair_coefficients, 1.0)
    assert configuration.composition().formula_unit_fractions == (2.0 / 3.0, 1.0 / 3.0)
    assert result.pair_count == 21
    assert result.energy.atomic_energies == pytest.approx(expected_atomic, abs=ENERGY_ABS_TOL, rel=0.0)
    assert result.energy.total_energy == pytest.approx(fsum(expected_atomic), abs=ENERGY_ABS_TOL, rel=0.0)
    for index in range(configuration.atom_count):
        for axis in range(3):
            expected = _independent_force_component(configuration, model.pair_coefficients, 1.0, index, axis)
            assert result.forces.forces[index][axis] == pytest.approx(expected, abs=FORCE_ABS_TOL, rel=0.0)
    assert all(abs(fsum(row[a] for row in result.forces.forces)) < 1e-12 for a in range(3))


def test_cartesian_length_scaling_for_coulomb_only() -> None:
    configuration = _configuration(("Li", "F"), ((0.0, 0.0, 0.0), (2.0, 0.0, 0.0)))
    first = _model(coulomb_only=True, length_unit_to_bohr=1.0).evaluate(configuration)
    second = _model(coulomb_only=True, length_unit_to_bohr=2.0).evaluate(configuration)
    assert second.energy.total_energy == pytest.approx(first.energy.total_energy / 2.0)
    assert second.forces.forces[0][0] == pytest.approx(first.forces.forces[0][0] / 2.0)
    assert second.length_unit_to_bohr == 2.0


def test_e3_rotation_reflection_and_translation_transform_forces() -> None:
    configuration = _configuration()
    model = _model()
    result = model.evaluate(configuration)
    operations = (
        lambda p: (-p[1] + 3.0, p[0] - 2.0, p[2] + 1.0),
        lambda p: (-p[0] + 4.0, p[1] + 5.0, p[2] - 2.0),
    )
    vector_actions = (
        lambda v: (-v[1], v[0], v[2]),
        lambda v: (-v[0], v[1], v[2]),
    )
    for transform, rotate_vector in zip(operations, vector_actions, strict=True):
        changed = _configuration(SPECIES, tuple(transform(p) for p in POSITIONS))
        observed = model.evaluate(changed)
        assert observed.energy.total_energy == pytest.approx(result.energy.total_energy, abs=1e-11)
        assert observed.energy.atomic_energies == pytest.approx(result.energy.atomic_energies, abs=1e-11)
        for actual, original in zip(observed.forces.forces, result.forces.forces, strict=True):
            assert actual == pytest.approx(rotate_vector(original), abs=1e-10)


def test_species_and_coordinate_permutation_covariance() -> None:
    model = _model()
    baseline = model.evaluate(_configuration())
    indices = (6, 2, 0, 4, 1, 5, 3)
    changed = model.evaluate(_configuration(
        tuple(SPECIES[i] for i in indices),
        tuple(POSITIONS[i] for i in indices),
    ))
    assert changed.energy.total_energy == pytest.approx(baseline.energy.total_energy, abs=1e-11)
    assert changed.energy.atomic_energies == pytest.approx(
        tuple(baseline.energy.atomic_energies[i] for i in indices), abs=1e-11
    )
    for actual, index in zip(changed.forces.forces, indices, strict=True):
        assert actual == pytest.approx(baseline.forces.forces[index], abs=1e-10)


def test_all_six_pair_channels_contribute_in_fourteen_atom_fixture() -> None:
    doubled = tuple(POSITIONS) + tuple((p[0] + 6.0, p[1], p[2]) for p in POSITIONS)
    configuration = _configuration(SPECIES + SPECIES, doubled)
    baseline = _model().evaluate(configuration)
    assert configuration.composition().formula_unit_fractions == (2.0 / 3.0, 1.0 / 3.0)
    assert baseline.pair_count == 91
    coefficients = _coefficients()
    for index in range(6):
        changed = list(coefficients)
        changed[index] = replace(
            changed[index], born_amplitude_hartree=changed[index].born_amplitude_hartree + 0.01
        )
        result = FLiBeIndependentPairModel(
            model_id=f"SENSITIVITY-PAIR-{index}",
            pair_coefficients=tuple(changed),
            length_unit_to_bohr=1.0,
        ).evaluate(configuration)
        assert result.energy.total_energy > baseline.energy.total_energy


def test_replay_result_provenance_and_immutable_records() -> None:
    model = _model()
    first = model.evaluate(_configuration())
    second = model.evaluate(_configuration())
    assert first == second
    assert first.model_id == model.model_id
    assert first.pair_functional_id == PAIR_FUNCTIONAL_ID
    assert first.pair_coefficients == model.pair_coefficients
    assert all(pair.provenance is PROVENANCE for pair in first.pair_coefficients)
    with pytest.raises(FrozenInstanceError):
        first.model_id = "CHANGED"  # type: ignore[misc]
    with pytest.raises(FrozenInstanceError):
        model.pair_coefficients[0].source_id = "CHANGED"  # type: ignore[misc]


@pytest.mark.parametrize(
    ("field", "invalid", "error"),
    (
        ("born_amplitude_hartree", -0.1, ValueError),
        ("born_decay_inverse_bohr", float("nan"), ValueError),
        ("c6_hartree_bohr6", -0.01, ValueError),
        ("c8_hartree_bohr8", float("inf"), ValueError),
        ("b6_inverse_bohr", False, TypeError),
        ("b8_inverse_bohr", "0.5", TypeError),
        ("provenance", "TEST_FIXTURE", TypeError),
        ("source_id", "", ValueError),
        ("source_location", " spaced ", ValueError),
        ("species_a", "Li", TypeError),
    ),
)
def test_pair_coefficient_rejects_invalid_inputs(field, invalid, error) -> None:
    with pytest.raises(error):
        replace(_coefficients()[0], **{field: invalid})


@pytest.mark.parametrize(
    ("field", "strength", "damping"),
    (
        ("born_amplitude_hartree", 0.1, "born_decay_inverse_bohr"),
        ("c6_hartree_bohr6", 0.1, "b6_inverse_bohr"),
        ("c8_hartree_bohr8", 0.1, "b8_inverse_bohr"),
    ),
)
def test_nonzero_radial_term_requires_its_decay_parameter(field, strength, damping) -> None:
    with pytest.raises(ValueError, match="requires positive"):
        replace(_coefficients()[0], **{field: strength, damping: 0.0})


@pytest.mark.parametrize("invalid", (0.0, -1.0, float("inf"), float("nan")))
def test_model_rejects_invalid_coordinate_to_bohr_factor(invalid) -> None:
    with pytest.raises(ValueError, match="length_unit_to_bohr"):
        replace(_model(), length_unit_to_bohr=invalid)


def test_model_rejects_noncanonical_pair_tables_and_identifiers() -> None:
    model = _model()
    with pytest.raises(ValueError, match="six canonical pairs"):
        replace(model, pair_coefficients=model.pair_coefficients[:-1])
    with pytest.raises(ValueError, match="canonical pair order"):
        replace(model, pair_coefficients=tuple(reversed(model.pair_coefficients)))
    with pytest.raises(TypeError, match="FLiBePairCoefficients"):
        replace(model, pair_coefficients=(object(),) + model.pair_coefficients[1:])
    with pytest.raises((TypeError, ValueError), match="model_id"):
        replace(model, model_id=" ")


def test_nonperiodic_stoichiometry_and_distance_boundaries() -> None:
    model = _model()
    with pytest.raises(TypeError, match="FLiBeConfiguration"):
        model.evaluate(None)  # type: ignore[arg-type]
    with pytest.raises(ValueError, match="nonperiodic axes"):
        model.evaluate(_configuration(periodic=True))
    with pytest.raises(ValueError, match="fluorine stoichiometry"):
        model.evaluate(_configuration(("Li", "Be", "F"), ((0, 0, 0), (1, 0, 0), (0, 1, 0))))
    with pytest.raises(ValueError, match="pair distances"):
        model.evaluate(_configuration(("Li", "F"), ((0, 0, 0), (0, 0, 0))))


def test_result_rejects_corrupted_energy_force_and_metadata_contract() -> None:
    result = _model().evaluate(_configuration())
    with pytest.raises(ValueError, match="cardinalities"):
        replace(result, energy=EnergyState((0.0,), 0.0))
    with pytest.raises(ValueError, match="cardinalities"):
        replace(result, forces=ForceState(((0.0, 0.0, 0.0),)))
    with pytest.raises(ValueError, match="pair count"):
        replace(result, pair_count=20)
    with pytest.raises(ValueError, match="pair functional identifier"):
        replace(result, pair_functional_id="OTHER")
    with pytest.raises(ValueError, match="coefficient identities"):
        replace(result, pair_coefficients=tuple(reversed(result.pair_coefficients)))

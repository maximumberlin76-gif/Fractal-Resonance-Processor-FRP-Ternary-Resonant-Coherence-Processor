"""Independent stationary fluoride-dipole and energy qualification for FLiBe."""

from __future__ import annotations

import hashlib
from dataclasses import FrozenInstanceError, replace
from math import exp, factorial, fsum, isfinite, sqrt
from pathlib import Path

import pytest

from tr_eif.configuration import AtomicConfiguration
from tr_eif.flibe.configuration import FLiBeConfiguration
from tr_eif.flibe.finite_cluster_polarization import (
    POLARIZATION_FUNCTIONAL_ID,
    FLiBeFiniteClusterPolarizationModel,
    FLiBeFiniteClusterPolarizationResult,
)
from tr_eif.flibe.registered_pair_coefficients import (
    SOURCE_DOI,
    load_flibe_registered_pair_parameters,
)
from tr_eif.flibe.units import ParameterProvenance


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "data/reference/flibe_smith_2020_pim_pair_coefficients.json"
SPECIES = ("Li", "Li", "Be", "F", "F", "F", "F")
POSITIONS_BOHR = (
    (0.0, 0.0, 0.0),
    (8.0, 0.0, 0.0),
    (4.0, 7.0, 0.0),
    (2.0, 1.0, 6.0),
    (8.0, 5.0, 6.0),
    (1.0, 8.0, 8.0),
    (8.0, 10.0, 11.0),
)
FORMAL_CHARGES = {"Li": 1, "Be": 2, "F": -1}
ALPHA_F = 7.09
CATION_DAMPING = {"Li": (1.81, 1.40), "Be": (1.78, 0.99)}
STATIONARITY_TOL = 1.0e-10
ENERGY_TOL = 2.0e-11
DIPOLE_TOL = 2.0e-11


def _parameters():
    return load_flibe_registered_pair_parameters(SOURCE)


def _model(**changes):
    arguments = {
        "model_id": "FLIBE-POLARIZATION-INDEPENDENT-TEST",
        "parameters": _parameters(),
        "coordinate_unit_to_bohr": 1.0,
        "stationarity_absolute_tolerance": STATIONARITY_TOL,
    }
    arguments.update(changes)
    return FLiBeFiniteClusterPolarizationModel(**arguments)


def _configuration(species=SPECIES, positions=POSITIONS_BOHR, *, periodic=False):
    return FLiBeConfiguration(AtomicConfiguration(
        species=tuple(species),
        positions=tuple(tuple(float(x) for x in row) for row in positions),
        cell=((20.0, 0.0, 0.0), (0.0, 20.0, 0.0), (0.0, 0.0, 20.0)) if periodic else None,
        periodic=(periodic, periodic, periodic),
    ))


def _lif(distance=4.0):
    return _configuration(("Li", "F"), ((0.0, 0.0, 0.0), (distance, 0.0, 0.0)))


def _bef2(distance=4.0):
    return _configuration(
        ("Be", "F", "F"),
        ((0.0, 0.0, 0.0), (distance, 0.0, 0.0), (-distance, 0.0, 0.0)),
    )


def _damping(beta, c, radius):
    """Independent factorial-series evaluation of source charge-field damping."""
    z = beta * radius
    return 1.0 - c * exp(-z) * fsum(z**k / factorial(k) for k in range(5))


def _independent_linear_system(configuration):
    """Build the fluoride charge field and dipolar Hessian from pair geometry."""
    species = configuration.configuration.species
    positions = configuration.configuration.positions
    fluoride = tuple(i for i, item in enumerate(species) if item == "F")
    dimension = 3 * len(fluoride)
    matrix = [[0.0] * dimension for _ in range(dimension)]
    field = [0.0] * dimension
    for i in range(dimension):
        matrix[i][i] = 1.0 / ALPHA_F
    for local_i, atomic_i in enumerate(fluoride):
        for atomic_j, source_species in enumerate(species):
            if atomic_i == atomic_j:
                continue
            displacement = tuple(
                positions[atomic_i][axis] - positions[atomic_j][axis]
                for axis in range(3)
            )
            radius_squared = fsum(value * value for value in displacement)
            radius = sqrt(radius_squared)
            beta_c = CATION_DAMPING.get(source_species)
            damping = _damping(*beta_c, radius) if beta_c is not None else 1.0
            coefficient = FORMAL_CHARGES[source_species] * damping / radius**3
            for axis in range(3):
                field[3 * local_i + axis] += coefficient * displacement[axis]
        for local_j in range(local_i + 1, len(fluoride)):
            atomic_j = fluoride[local_j]
            displacement = tuple(
                positions[atomic_i][axis] - positions[atomic_j][axis]
                for axis in range(3)
            )
            radius_squared = fsum(value * value for value in displacement)
            radius = sqrt(radius_squared)
            for a in range(3):
                for b in range(3):
                    dipole_tensor = (
                        3.0 * displacement[a] * displacement[b] / radius**5
                        - (1.0 / radius**3 if a == b else 0.0)
                    )
                    matrix[3 * local_i + a][3 * local_j + b] = -dipole_tensor
                    matrix[3 * local_j + b][3 * local_i + a] = -dipole_tensor
    return fluoride, matrix, field


def _gaussian_solution(matrix, field):
    """Partial-pivot Gaussian elimination independent of the model Cholesky solver."""
    n = len(field)
    augmented = [list(matrix[i]) + [field[i]] for i in range(n)]
    for k in range(n):
        pivot = max(range(k, n), key=lambda row: abs(augmented[row][k]))
        assert abs(augmented[pivot][k]) > 1.0e-14
        augmented[k], augmented[pivot] = augmented[pivot], augmented[k]
        for row in range(k + 1, n):
            ratio = augmented[row][k] / augmented[k][k]
            for column in range(k, n + 1):
                augmented[row][column] -= ratio * augmented[k][column]
    result = [0.0] * n
    for row in range(n - 1, -1, -1):
        result[row] = (
            augmented[row][n]
            - fsum(augmented[row][j] * result[j] for j in range(row + 1, n))
        ) / augmented[row][row]
    return tuple(result)


def _independent_reference(configuration):
    """Evaluate stationary dipoles and the quadratic energy independently."""
    fluoride, hessian, field = _independent_linear_system(configuration)
    dipoles_flat = _gaussian_solution(hessian, field)
    induced = [(0.0, 0.0, 0.0)] * configuration.atom_count
    charge_fields = [(0.0, 0.0, 0.0)] * configuration.atom_count
    for index, atomic_index in enumerate(fluoride):
        induced[atomic_index] = tuple(dipoles_flat[3 * index + a] for a in range(3))
        charge_fields[atomic_index] = tuple(field[3 * index + a] for a in range(3))
    quadratic = 0.5 * fsum(
        dipoles_flat[i] * hessian[i][j] * dipoles_flat[j]
        for i in range(len(field)) for j in range(len(field))
    )
    linear = fsum(dipoles_flat[i] * field[i] for i in range(len(field)))
    energy = quadratic - linear
    residual = max(
        abs(fsum(hessian[i][j] * dipoles_flat[j] for j in range(len(field))) - field[i])
        for i in range(len(field))
    )
    return fluoride, tuple(induced), tuple(charge_fields), energy, residual, hessian, field, dipoles_flat


def _compare_vectors(actual, expected, tolerance=DIPOLE_TOL):
    assert len(actual) == len(expected)
    for observed, reference in zip(actual, expected, strict=True):
        assert observed == pytest.approx(reference, rel=0.0, abs=tolerance)


def test_lif_analytic_single_fluoride_dipole_and_stationary_energy():
    """One fluoride has a diagonal 1/alpha Hessian and no dipole pair term."""
    r = 4.0
    field_x = _damping(1.81, 1.40, r) / r**2
    expected_mu = ALPHA_F * field_x
    expected_pol = -0.5 * ALPHA_F * field_x**2
    result = _model().evaluate(_lif(r))
    assert result.polarizable_indices == (1,)
    _compare_vectors(result.induced_dipoles_e_bohr, (
        (0.0, 0.0, 0.0), (expected_mu, 0.0, 0.0)
    ))
    assert result.charge_fields_atomic[1] == pytest.approx((field_x, 0.0, 0.0))
    assert result.self_energy_hartree == pytest.approx(-expected_pol, abs=ENERGY_TOL)
    assert result.charge_dipole_energy_hartree == pytest.approx(2.0 * expected_pol, abs=ENERGY_TOL)
    assert result.dipole_dipole_energy_hartree == 0.0
    assert result.polarization_energy_hartree == pytest.approx(expected_pol, abs=ENERGY_TOL)
    assert result.polarization_energy_hartree == pytest.approx(-0.0085750259738901, abs=ENERGY_TOL)
    assert result.max_stationarity_residual_atomic <= STATIONARITY_TOL


def test_bef2_symmetric_two_fluoride_solution_includes_dipole_coupling():
    """Opposite fluoride fields yield opposite dipoles coupled along their axis."""
    distance = 4.0
    separation = 2.0 * distance
    field = 2.0 * _damping(1.78, 0.99, distance) / distance**2 - 1.0 / separation**2
    dipole = field / (1.0 / ALPHA_F + 2.0 / separation**3)
    result = _model().evaluate(_bef2(distance))
    assert result.polarizable_indices == (1, 2)
    _compare_vectors(result.induced_dipoles_e_bohr, (
        (0.0, 0.0, 0.0), (dipole, 0.0, 0.0), (-dipole, 0.0, 0.0)
    ))
    assert result.charge_fields_atomic[1] == pytest.approx((field, 0.0, 0.0))
    assert result.charge_fields_atomic[2] == pytest.approx((-field, 0.0, 0.0))
    assert result.polarization_energy_hartree == pytest.approx(-dipole * field, abs=ENERGY_TOL)
    assert result.dipole_dipole_energy_hartree != pytest.approx(0.0, abs=1.0e-9)


def test_seven_atom_stationary_dipoles_match_independent_gaussian_solver():
    configuration = _configuration()
    result = _model().evaluate(configuration)
    fluoride, dipoles, fields, energy, residual, _, _, _ = _independent_reference(configuration)
    assert fluoride == (3, 4, 5, 6)
    assert result.polarizable_indices == fluoride
    _compare_vectors(result.induced_dipoles_e_bohr, dipoles)
    _compare_vectors(result.charge_fields_atomic, fields)
    assert result.polarization_energy_hartree == pytest.approx(energy, abs=ENERGY_TOL)
    assert result.max_stationarity_residual_atomic <= STATIONARITY_TOL
    assert residual <= STATIONARITY_TOL
    assert result.pair_result.pair_count == 21
    assert result.total_energy_hartree == pytest.approx(
        fsum((result.pair_result.energy.total_energy, energy)), abs=ENERGY_TOL
    )


def test_stationary_energy_is_a_local_minimum_in_fluoride_dipole_space():
    configuration = _configuration()
    result = _model().evaluate(configuration)
    _, _, _, energy, _, hessian, field, flat = _independent_reference(configuration)
    shifted = list(flat)
    shifted[0] += 0.01
    shifted_energy = 0.5 * fsum(
        shifted[i] * hessian[i][j] * shifted[j]
        for i in range(len(shifted)) for j in range(len(shifted))
    ) - fsum(shifted[i] * field[i] for i in range(len(field)))
    assert shifted_energy > energy
    assert shifted_energy - energy == pytest.approx(0.01**2 / (2.0 * ALPHA_F), abs=1.0e-12)
    assert result.polarization_energy_hartree == pytest.approx(energy, abs=ENERGY_TOL)


def test_source_provenance_and_pair_energy_partition():
    parameters = _parameters()
    result = _model(parameters=parameters).evaluate(_configuration())
    assert result.functional_id == POLARIZATION_FUNCTIONAL_ID
    assert result.model_id == "FLIBE-POLARIZATION-INDEPENDENT-TEST"
    assert result.source_doi == SOURCE_DOI
    assert result.source_file_sha256 == hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    assert all(pair.provenance is ParameterProvenance.PRIMARY_SOURCE
               for pair in result.pair_result.pair_coefficients)
    expected_pair = parameters.build_finite_cluster_model(
        model_id="INDEPENDENT-PAIR-REFERENCE", coordinate_unit_to_bohr=1.0
    ).evaluate(_configuration())
    assert result.pair_result.energy == expected_pair.energy
    assert result.pair_result.forces == expected_pair.forces
    assert result.polarization_energy_hartree == pytest.approx(fsum((
        result.self_energy_hartree,
        result.charge_dipole_energy_hartree,
        result.dipole_dipole_energy_hartree,
    )), abs=ENERGY_TOL)
    assert result.polarization_energy_hartree == pytest.approx(
        0.5 * result.charge_dipole_energy_hartree, abs=ENERGY_TOL
    )


def test_e3_rotation_translation_covariance_of_fields_and_dipoles():
    def rotation(v):
        return (-v[1], v[0], v[2])
    rotated = tuple(tuple(rotation(position)[a] + (3.0, -5.0, 1.0)[a]
                          for a in range(3)) for position in POSITIONS_BOHR)
    original = _model().evaluate(_configuration())
    transformed = _model().evaluate(_configuration(positions=rotated))
    assert transformed.polarization_energy_hartree == pytest.approx(
        original.polarization_energy_hartree, abs=ENERGY_TOL
    )
    assert transformed.total_energy_hartree == pytest.approx(
        original.total_energy_hartree, abs=ENERGY_TOL
    )
    _compare_vectors(transformed.induced_dipoles_e_bohr,
                     tuple(rotation(v) for v in original.induced_dipoles_e_bohr))
    _compare_vectors(transformed.charge_fields_atomic,
                     tuple(rotation(v) for v in original.charge_fields_atomic))


def test_atomic_permutation_covariance_of_polarization():
    indices = (6, 2, 0, 4, 1, 5, 3)
    original = _model().evaluate(_configuration())
    reordered = _model().evaluate(_configuration(
        species=tuple(SPECIES[i] for i in indices),
        positions=tuple(POSITIONS_BOHR[i] for i in indices),
    ))
    assert reordered.polarization_energy_hartree == pytest.approx(
        original.polarization_energy_hartree, abs=ENERGY_TOL
    )
    assert reordered.total_energy_hartree == pytest.approx(
        original.total_energy_hartree, abs=ENERGY_TOL
    )
    _compare_vectors(reordered.induced_dipoles_e_bohr,
                     tuple(original.induced_dipoles_e_bohr[i] for i in indices))
    _compare_vectors(reordered.charge_fields_atomic,
                     tuple(original.charge_fields_atomic[i] for i in indices))
    assert reordered.polarizable_indices == (0, 3, 5, 6)


def test_coordinate_to_bohr_factor_preserves_identical_physical_geometry():
    reference = _model().evaluate(_lif(4.0))
    doubled = _model(coordinate_unit_to_bohr=0.5).evaluate(_lif(8.0))
    assert doubled.induced_dipoles_e_bohr == reference.induced_dipoles_e_bohr
    assert doubled.charge_fields_atomic == reference.charge_fields_atomic
    assert doubled.polarization_energy_hartree == pytest.approx(
        reference.polarization_energy_hartree, abs=ENERGY_TOL
    )
    assert doubled.total_energy_hartree == pytest.approx(
        reference.total_energy_hartree, abs=ENERGY_TOL
    )


def test_lif_polarization_decreases_with_ionic_separation():
    near = _model().evaluate(_lif(4.0))
    far = _model().evaluate(_lif(8.0))
    assert near.source_doi == far.source_doi == SOURCE_DOI
    assert near.source_file_sha256 == far.source_file_sha256
    assert abs(far.charge_fields_atomic[1][0]) < abs(near.charge_fields_atomic[1][0])
    assert abs(far.induced_dipoles_e_bohr[1][0]) < abs(near.induced_dipoles_e_bohr[1][0])
    assert abs(far.polarization_energy_hartree) < abs(near.polarization_energy_hartree)


def test_bef2_geometry_changes_dipole_coupling_with_source_parameters_fixed():
    original = _model().evaluate(_bef2(4.0))
    right_angle = _configuration(
        ("Be", "F", "F"),
        ((0.0, 0.0, 0.0), (4.0, 0.0, 0.0), (0.0, 4.0, 0.0)),
    )
    result = _model().evaluate(right_angle)
    _, dipoles, fields, reference_energy, _, _, _, _ = _independent_reference(right_angle)
    _compare_vectors(result.induced_dipoles_e_bohr, dipoles)
    _compare_vectors(result.charge_fields_atomic, fields)
    assert result.polarization_energy_hartree == pytest.approx(reference_energy, abs=ENERGY_TOL)
    assert result.polarization_energy_hartree != pytest.approx(
        original.polarization_energy_hartree, abs=ENERGY_TOL
    )
    assert result.source_file_sha256 == original.source_file_sha256


def test_polarization_hessian_rejects_short_range_instability():
    with pytest.raises(ValueError, match="positive definite"):
        _model().evaluate(_bef2(0.25))


def test_strict_stationarity_tolerance_checks_numerical_residual():
    with pytest.raises(ValueError, match="stationary dipole residual"):
        _model(stationarity_absolute_tolerance=1.0e-24).evaluate(_lif())


def test_rejects_periodic_configuration_and_invalid_ionic_inventory():
    with pytest.raises(ValueError, match="nonperiodic axes"):
        _model().evaluate(_configuration(periodic=True))
    with pytest.raises(ValueError, match="fluorine stoichiometry"):
        _model().evaluate(_configuration(("Li", "F", "F"),
            ((0.0, 0.0, 0.0), (3.0, 0.0, 0.0), (-3.0, 0.0, 0.0))))
    with pytest.raises(ValueError, match="positive separation"):
        _model().evaluate(_lif(0.0))
    with pytest.raises(TypeError, match="FLiBeConfiguration"):
        _model().evaluate(None)


@pytest.mark.parametrize(
    ("field", "invalid", "error"),
    (
        ("model_id", " ", ValueError),
        ("model_id", None, TypeError),
        ("parameters", None, TypeError),
        ("coordinate_unit_to_bohr", 0.0, ValueError),
        ("coordinate_unit_to_bohr", float("nan"), ValueError),
        ("coordinate_unit_to_bohr", False, TypeError),
        ("stationarity_absolute_tolerance", -1.0, ValueError),
        ("stationarity_absolute_tolerance", float("inf"), ValueError),
        ("stationarity_absolute_tolerance", True, TypeError),
    ),
)
def test_model_constructor_rejects_invalid_contracts(field, invalid, error):
    with pytest.raises(error):
        _model(**{field: invalid})


def test_result_constructor_rejects_broken_energy_and_provenance():
    result = _model().evaluate(_lif())
    assert isinstance(result, FLiBeFiniteClusterPolarizationResult)
    with pytest.raises(ValueError, match="polarization components"):
        replace(result, polarization_energy_hartree=result.polarization_energy_hartree + 0.1)
    with pytest.raises(ValueError, match="pair and polarization"):
        replace(result, total_energy_hartree=result.total_energy_hartree + 0.1)
    with pytest.raises(ValueError, match="functional identifier"):
        replace(result, functional_id="OTHER")
    with pytest.raises(ValueError, match="SHA-256"):
        replace(result, source_file_sha256="bad")
    with pytest.raises(ValueError, match="fluoride ions"):
        replace(result, polarizable_indices=(0,))
    with pytest.raises(ValueError, match="only fluoride"):
        replace(result, induced_dipoles_e_bohr=((1.0, 0.0, 0.0), result.induced_dipoles_e_bohr[1]))
    with pytest.raises(ValueError, match="nonnegative"):
        replace(result, max_stationarity_residual_atomic=-1.0)
    with pytest.raises(FrozenInstanceError):
        result.model_id = "ALTERED"  # type: ignore[misc]


def test_repeat_execution_uses_identical_source_and_dipole_order():
    first = _model().evaluate(_configuration())
    second = _model().evaluate(_configuration())
    assert first == second
    assert first.source_file_sha256 == second.source_file_sha256
    assert all(isfinite(component) for dipole in first.induced_dipoles_e_bohr
               for component in dipole)

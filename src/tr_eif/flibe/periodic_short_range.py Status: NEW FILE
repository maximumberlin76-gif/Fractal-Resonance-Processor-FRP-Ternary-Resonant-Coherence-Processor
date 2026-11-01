"""Periodic Born-Mayer and damped dispersion energy for registered FLiBe ions.

The short-range radial pair law is

    U_sr(r) = A_ij exp(-alpha_ij r)
              - C6_ij f6(b6_ij r)/r**6
              - C8_ij f8(b8_ij r)/r**8.

The finite periodic lattice sum includes distinct-atom image interactions
and half-weighted same-atom nonzero images. Formal-charge Coulomb terms are
reserved for the separately defined three-dimensional Ewald operator.
Coordinates use an explicit conversion to bohr; energies are hartree and
forces are hartree per input Cartesian coordinate unit. The integer image
shell is an explicit numerical truncation parameter.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import exp, fsum, isclose, isfinite, sqrt
from typing import TypeAlias

from tr_eif.energy import EnergyState, ForceState

from .configuration import FLiBeConfiguration
from .independent_pair_potential import PAIR_ORDER, FLiBePairCoefficients, _damped_inverse_power
from .registered_pair_coefficients import FLiBeRegisteredPairParameters
from .species import FLIBE_SPECIES


Vector3: TypeAlias = tuple[float, float, float]
Cell3: TypeAlias = tuple[Vector3, Vector3, Vector3]
SHORT_RANGE_FUNCTIONAL_ID = "flibe.periodic.born_mayer_tt.v1"


def _positive(value: float, name: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise TypeError(f"{name} must be a real non-Boolean number.")
    number = float(value)
    if not isfinite(number) or number <= 0.0:
        raise ValueError(f"{name} must be finite and positive.")
    return number


def _name(value: str, name: str) -> str:
    if not isinstance(value, str):
        raise TypeError(f"{name} must be a string.")
    if not value or value != value.strip():
        raise ValueError(f"{name} must be a nonempty trimmed string.")
    return value


def _dot(a: Vector3, b: Vector3) -> float:
    return fsum(a[k] * b[k] for k in range(3))


def _cross(a: Vector3, b: Vector3) -> Vector3:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def _canonical_pair_delta(
    a: Vector3,
    b: Vector3,
    cell: Cell3,
    normals: Cell3,
    determinant: float,
) -> Vector3:
    """Choose a central fractional-image representative for one directed pair.

    The nearest-integer fractional reduction is antisymmetric under exchange
    of atoms and invariant under integer-cell translations of either atom.
    A finite image shell remains a declared truncation of the lattice sum.
    """
    delta = tuple(a[axis] - b[axis] for axis in range(3))
    fractions = tuple(_dot(delta, normal) / determinant for normal in normals)
    if any(not isfinite(value) for value in fractions):
        raise ValueError("pair fractional coordinates must be finite.")
    offsets = tuple(round(value) for value in fractions)
    return tuple(fsum((delta[axis], *(
        -offsets[k] * cell[k][axis] for k in range(3)
    ))) for axis in range(3))  # type: ignore[return-value]


def _short_range_radial(
    pair: FLiBePairCoefficients,
    r: float,
) -> tuple[float, float]:
    """Return short-range energy and derivative dU_sr/dr in atomic units."""
    born = pair.born_amplitude_hartree * exp(-pair.born_decay_inverse_bohr * r)
    value = born
    derivative = -pair.born_decay_inverse_bohr * born

    for order, coefficient, damping in (
        (6, pair.c6_hartree_bohr6, pair.b6_inverse_bohr),
        (8, pair.c8_hartree_bohr8, pair.b8_inverse_bohr),
    ):
        if coefficient:
            term, radial_derivative = _damped_inverse_power(r, damping, order)
            value -= coefficient * term
            derivative -= coefficient * radial_derivative

    if not isfinite(value) or not isfinite(derivative):
        raise ValueError("periodic short-range energy and derivative must be finite.")
    return value, derivative


@dataclass(frozen=True, slots=True)
class FLiBePeriodicShortRangeResult:
    """Source-resolved periodic short-range energies and Cartesian forces."""

    configuration: FLiBeConfiguration
    model_id: str
    functional_id: str
    parameters: FLiBeRegisteredPairParameters
    coordinate_unit_to_bohr: float
    image_shell: int
    cross_atom_image_terms: int
    self_atom_image_terms: int
    cross_atom_energy_hartree: float
    self_image_energy_hartree: float
    energy: EnergyState
    forces: ForceState

    def __post_init__(self) -> None:
        if not isinstance(self.configuration, FLiBeConfiguration):
            raise TypeError("configuration must be FLiBeConfiguration.")
        _name(self.model_id, "model_id")

        if self.functional_id != SHORT_RANGE_FUNCTIONAL_ID:
            raise ValueError("short-range functional identity differs.")

        if not isinstance(self.parameters, FLiBeRegisteredPairParameters):
            raise TypeError("parameters must be FLiBeRegisteredPairParameters.")

        _positive(self.coordinate_unit_to_bohr, "coordinate_unit_to_bohr")

        if isinstance(self.image_shell, bool) or not isinstance(self.image_shell, int):
            raise TypeError("image_shell must be an integer.")
        if self.image_shell < 0:
            raise ValueError("image_shell must be nonnegative.")

        atom_count = self.configuration.atom_count
        image_count = (2 * self.image_shell + 1) ** 3

        if self.cross_atom_image_terms != atom_count * (atom_count - 1) // 2 * image_count:
            raise ValueError("cross-atom image term count differs.")

        if self.self_atom_image_terms != atom_count * (image_count - 1):
            raise ValueError("self-atom image term count differs.")

        if not isinstance(self.energy, EnergyState) or not isinstance(self.forces, ForceState):
            raise TypeError("energy and forces must use their typed states.")

        if self.energy.atom_count != atom_count or self.forces.atom_count != atom_count:
            raise ValueError("energy and force cardinalities must match the configuration.")

        if any(not isfinite(value) for value in (
            self.cross_atom_energy_hartree,
            self.self_image_energy_hartree,
        )):
            raise ValueError("short-range component energies must be finite.")

        if not isclose(self.energy.total_energy, fsum((
            self.cross_atom_energy_hartree,
            self.self_image_energy_hartree,
        )), rel_tol=1e-12, abs_tol=1e-12):
            raise ValueError("short-range components must sum to total energy.")

        if not isclose(
            self.energy.total_energy,
            fsum(self.energy.atomic_energies),
            rel_tol=1e-12,
            abs_tol=1e-12,
        ):
            raise ValueError("short-range atomic partition must sum to total energy.")

    @property
    def source_doi(self) -> str:
        """Return the primary source DOI for the coefficient table."""
        return self.parameters.source_doi

    @property
    def source_file_sha256(self) -> str:
        """Return the exact registered parameter-file fingerprint."""
        return self.parameters.source_file_sha256


@dataclass(frozen=True, slots=True)
class FLiBePeriodicShortRangeModel:
    """Truncated periodic short-range ionic pair model with primary-source inputs.

    Every distinct atom pair interacts with the symmetric set of lattice
    translations. Same-atom interactions with nonzero lattice translations
    enter energy at half weight and have zero positional derivative.
    The source-registered Coulomb term is delegated to the Ewald model.
    """

    model_id: str
    parameters: FLiBeRegisteredPairParameters
    coordinate_unit_to_bohr: float
    image_shell: int

    def __post_init__(self) -> None:
        _name(self.model_id, "model_id")

        if not isinstance(self.parameters, FLiBeRegisteredPairParameters):
            raise TypeError("parameters must be FLiBeRegisteredPairParameters.")

        _positive(self.coordinate_unit_to_bohr, "coordinate_unit_to_bohr")

        if isinstance(self.image_shell, bool) or not isinstance(self.image_shell, int):
            raise TypeError("image_shell must be an integer.")
        if self.image_shell < 0:
            raise ValueError("image_shell must be nonnegative.")

    def evaluate(
        self,
        configuration: FLiBeConfiguration,
    ) -> FLiBePeriodicShortRangeResult:
        """Evaluate all declared periodic image terms and their exact radial forces."""
        if not isinstance(configuration, FLiBeConfiguration):
            raise TypeError("configuration must be FLiBeConfiguration.")

        atomic = configuration.configuration

        if atomic.periodic != (True, True, True) or atomic.cell is None:
            raise ValueError("periodic short-range requires three periodic axes and a cell.")

        configuration.composition()
        factor = self.coordinate_unit_to_bohr

        cell = tuple(
            tuple(factor * component for component in vector)
            for vector in atomic.cell
        )
        positions = tuple(
            tuple(factor * component for component in row)
            for row in atomic.positions
        )

        if any(
            not isfinite(component)
            for vector in (*cell, *positions)
            for component in vector
        ):
            raise ValueError("cell and atomic Cartesian coordinates must be finite in bohr.")

        normals = (
            _cross(cell[1], cell[2]),
            _cross(cell[2], cell[0]),
            _cross(cell[0], cell[1]),
        )
        determinant = _dot(cell[0], normals[0])

        if not isfinite(determinant) or determinant == 0.0:
            raise ValueError("periodic cell must have finite nonzero volume.")

        species = configuration.species
        order = {s: index for index, s in enumerate(FLIBE_SPECIES)}
        coefficients = dict(
            zip(PAIR_ORDER, self.parameters.pair_coefficients, strict=True)
        )
        atom_count = configuration.atom_count

        energy_terms = [[] for _ in range(atom_count)]
        force_terms = [[[] for _ in range(3)] for _ in range(atom_count)]
        cross_energy_terms: list[float] = []
        self_energy_terms: list[float] = []

        pair_records = []

        for i in range(atom_count):
            for j in range(i + 1, atom_count):
                pair_key = (species[i], species[j])

                if order[pair_key[0]] > order[pair_key[1]]:
                    pair_key = (pair_key[1], pair_key[0])

                base_delta = _canonical_pair_delta(
                    positions[i],
                    positions[j],
                    cell,
                    normals,
                    determinant,
                )  # type: ignore[arg-type]

                pair_records.append((i, j, coefficients[pair_key], base_delta))

        image_range = range(-self.image_shell, self.image_shell + 1)
        cross_terms = 0
        self_terms = 0

        for image in product(image_range, repeat=3):
            shift = tuple(
                fsum(image[k] * cell[k][axis] for k in range(3))
                for axis in range(3)
            )

            for i in range(atom_count):
                if image != (0, 0, 0):
                    pair = coefficients[(species[i], species[i])]
                    radius = sqrt(_dot(shift, shift))

                    if not isfinite(radius) or radius <= 0.0:
                        raise ValueError(
                            "same-atom image separation must be finite and positive."
                        )

                    energy, _ = _short_range_radial(pair, radius)
                    half = 0.5 * energy

                    self_energy_terms.append(half)
                    energy_terms[i].append(half)
                    self_terms += 1

            for i, j, pair, base_delta in pair_records:
                delta = tuple(
                    base_delta[axis] + shift[axis]
                    for axis in range(3)
                )
                radius = sqrt(_dot(delta, delta))

                if not isfinite(radius) or radius <= 0.0:
                    raise ValueError(
                        "distinct-atom periodic separation must be finite and positive."
                    )

                energy, derivative = _short_range_radial(pair, radius)

                cross_energy_terms.append(energy)
                energy_terms[i].append(0.5 * energy)
                energy_terms[j].append(0.5 * energy)

                scale = -factor * derivative / radius

                for axis in range(3):
                    contribution = scale * delta[axis]
                    force_terms[i][axis].append(contribution)
                    force_terms[j][axis].append(-contribution)

                cross_terms += 1

        atomic_energies = tuple(fsum(terms) for terms in energy_terms)
        forces = tuple(
            tuple(fsum(terms) for terms in atom)
            for atom in force_terms
        )

        cross_energy = fsum(cross_energy_terms)
        self_energy = fsum(self_energy_terms)
        total = fsum((cross_energy, self_energy))

        if any(not isfinite(v) for v in (
            *atomic_energies,
            total,
            *(component for row in forces for component in row),
        )):
            raise ValueError("periodic short-range energy and forces must be finite.")

        return FLiBePeriodicShortRangeResult(
            configuration=configuration,
            model_id=self.model_id,
            functional_id=SHORT_RANGE_FUNCTIONAL_ID,
            parameters=self.parameters,
            coordinate_unit_to_bohr=factor,
            image_shell=self.image_shell,
            cross_atom_image_terms=cross_terms,
            self_atom_image_terms=self_terms,
            cross_atom_energy_hartree=cross_energy,
            self_image_energy_hartree=self_energy,
            energy=EnergyState(atomic_energies, total),
            forces=ForceState(forces),
        )

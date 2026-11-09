
"""Multirate rank-two interatomic dynamics in the TR-EIF reference framework.

Phase integration, ternary execution, and mechanical integration retain distinct
schedules. A resonance descriptor augments invariant scalar features; retained
ternary states condition scalar, vector, and Cartesian rank-two channels. The
mechanical interval evaluates forces from the complete tensor-augmented energy
with its resonance channels and ternary execution frozen at that interval.

The trace separates fixed-geometry changes at phase/ternary events from
coordinate-driven changes during velocity-Verlet integration. Each committed
ternary route leg remains a separate event under the established executor.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isfinite

from tr_eif.configuration import AtomicConfiguration
from tr_eif.energy import ConservativeForceEvaluator
from tr_eif.energy.rank_two_model import (
    RankTwoConservativeEnergyModel,
    RankTwoConservativeEnergyResult,
    RankTwoConservativeForceEvaluator,
)
from tr_eif.equivariant.rank_two import ScalarVectorTensorFeatures
from tr_eif.graph import build_cutoff_graph
from tr_eif.resonance import (
    PhaseDynamicsParameters,
    ResonanceDescriptor,
    resonance_descriptor,
)
from tr_eif.ternary import (
    ResonanceProjection,
    TernaryExecutionGuard,
    TernaryState,
    TernaryTargetThresholds,
    TernaryVector,
)

from .coupled_execution import (
    CoupledMolecularDynamicsState,
    CoupledMolecularDynamicsStep,
    append_md_resonance_features,
    execute_coupled_md_step,
)
from .dynamics import accelerations_from_forces
from .execution import MolecularDynamicsStepResult
from .integrator import velocity_verlet_positions, velocity_verlet_velocities
from .state import MolecularDynamicsState


def _positive_real(value: float, name: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise TypeError(f"{name} must be a real non-Boolean number.")
    number = float(value)
    if not isfinite(number) or number <= 0.0:
        raise ValueError(f"{name} must be finite and positive.")
    return number


def _resonance_features(
    base: ScalarVectorTensorFeatures,
    descriptor: ResonanceDescriptor,
) -> ScalarVectorTensorFeatures:
    """Append two continuous resonance invariants, retaining tensor channels."""
    return ScalarVectorTensorFeatures(
        base=append_md_resonance_features(base.base, descriptor),
        rank_two=base.rank_two,
    )


def _rank_two_verlet_step(
    state: MolecularDynamicsState,
    model: RankTwoConservativeEnergyModel,
    evaluator: RankTwoConservativeForceEvaluator,
    features: ScalarVectorTensorFeatures,
    execution,
    cutoff: float,
    time_step: float,
) -> MolecularDynamicsStepResult:
    """Integrate one mechanical interval using full-energy Cartesian forces."""
    graph_before = build_cutoff_graph(state.configuration, cutoff)
    forces_before = evaluator.evaluate(
        model, state.configuration, graph_before, features, execution,
    )
    accelerations_before = accelerations_from_forces(
        forces_before, state.masses,
    )
    positions_after = velocity_verlet_positions(
        state.configuration.positions,
        state.velocities,
        accelerations_before,
        time_step,
    )
    configuration_after = AtomicConfiguration(
        species=state.configuration.species,
        positions=positions_after,
        cell=state.configuration.cell,
        periodic=state.configuration.periodic,
    )
    graph_after = build_cutoff_graph(configuration_after, cutoff)
    forces_after = evaluator.evaluate(
        model, configuration_after, graph_after, features, execution,
    )
    accelerations_after = accelerations_from_forces(
        forces_after, state.masses,
    )
    velocities_after = velocity_verlet_velocities(
        state.velocities,
        accelerations_before,
        accelerations_after,
        time_step,
    )
    updated = MolecularDynamicsState(
        configuration=configuration_after,
        velocities=velocities_after,
        masses=state.masses,
        step=state.step + 1,
        time=state.time + time_step,
    )
    return MolecularDynamicsStepResult(
        previous=state,
        current=updated,
        graph_before=graph_before,
        graph_after=graph_after,
        forces_before=forces_before,
        forces_after=forces_after,
    )


@dataclass(frozen=True, slots=True)
class RankTwoCoupledMolecularDynamicsStep:
    """Typed resonance, ternary, and tensor-force mechanical execution trace."""

    previous: CoupledMolecularDynamicsState
    current: CoupledMolecularDynamicsState
    event_update: CoupledMolecularDynamicsStep | None
    mechanical_update: MolecularDynamicsStepResult | None
    descriptor: ResonanceDescriptor
    features_before_events: ScalarVectorTensorFeatures
    features_after_events: ScalarVectorTensorFeatures
    energy_before_events: RankTwoConservativeEnergyResult
    energy_after_events: RankTwoConservativeEnergyResult
    energy_after_mechanics: RankTwoConservativeEnergyResult

    def __post_init__(self) -> None:
        if not isinstance(self.previous, CoupledMolecularDynamicsState):
            raise TypeError("previous must be CoupledMolecularDynamicsState.")
        if not isinstance(self.current, CoupledMolecularDynamicsState):
            raise TypeError("current must be CoupledMolecularDynamicsState.")
        if not isinstance(self.descriptor, ResonanceDescriptor):
            raise TypeError("descriptor must be ResonanceDescriptor.")
        for field in ("features_before_events", "features_after_events"):
            if not isinstance(getattr(self, field), ScalarVectorTensorFeatures):
                raise TypeError(f"{field} must be ScalarVectorTensorFeatures.")
        for field in (
            "energy_before_events", "energy_after_events", "energy_after_mechanics",
        ):
            if not isinstance(getattr(self, field), RankTwoConservativeEnergyResult):
                raise TypeError(f"{field} must be RankTwoConservativeEnergyResult.")
        if self.descriptor != resonance_descriptor(self.current.resonance_state):
            raise ValueError("descriptor must match current continuous resonance.")
        if self.features_before_events.rank_two != self.features_after_events.rank_two:
            raise ValueError("scheduled events must retain input tensor features.")
        if self.energy_before_events.layer.previous != self.features_before_events:
            raise ValueError("initial energy input must match initial feature channels.")
        if self.energy_after_events.layer.previous != self.features_after_events:
            raise ValueError("event energy input must match post-event feature channels.")
        if self.energy_after_mechanics.layer.previous != self.features_after_events:
            raise ValueError("mechanical energy must use frozen post-event features.")
        if self.event_update is None:
            if (
                self.current.resonance_state != self.previous.resonance_state
                or self.current.resonance_time != self.previous.resonance_time
                or self.current.resonance_step_count != self.previous.resonance_step_count
                or self.current.ternary_execution != self.previous.ternary_execution
                or self.current.ternary_event_count != self.previous.ternary_event_count
            ):
                raise ValueError("phase or ternary state changed without an event.")
            if self.energy_before_events != self.energy_after_events:
                raise ValueError("event-free potential energy must remain unchanged.")
        else:
            event = self.event_update
            if not isinstance(event, CoupledMolecularDynamicsStep):
                raise TypeError("event_update must be CoupledMolecularDynamicsStep.")
            if event.previous != self.previous or event.current.md_state != self.previous.md_state:
                raise ValueError("event update must use the preceding mechanical state.")
            if event.mechanical_update is not None:
                raise ValueError("event update must retain mechanical state.")
            if (
                self.current.resonance_state != event.current.resonance_state
                or self.current.resonance_time != event.current.resonance_time
                or self.current.resonance_step_count != event.current.resonance_step_count
                or self.current.ternary_execution != event.current.ternary_execution
                or self.current.ternary_event_count != event.current.ternary_event_count
            ):
                raise ValueError("event state differs from the final coupled state.")
            if self.energy_before_events.reference_energy != event.energy_before_events:
                raise ValueError("initial reference energy differs from the event executor.")
            if self.energy_after_events.reference_energy != event.energy_after_events:
                raise ValueError("post-event reference energy differs from the event executor.")
        if self.mechanical_update is None:
            if self.current.md_state != self.previous.md_state:
                raise ValueError("mechanical state changed without an MD step.")
            if self.energy_after_mechanics != self.energy_after_events:
                raise ValueError("mechanics-free potential energy must remain unchanged.")
        else:
            if not isinstance(self.mechanical_update, MolecularDynamicsStepResult):
                raise TypeError("mechanical_update must be MolecularDynamicsStepResult.")
            if (
                self.mechanical_update.previous != self.previous.md_state
                or self.mechanical_update.current != self.current.md_state
            ):
                raise ValueError("mechanical trajectory step differs from coupled state.")

    @property
    def requested_target(self) -> TernaryState | None:
        """Return the projected target, distinct from retained execution."""
        return None if self.event_update is None else self.event_update.requested_target

    @property
    def requested_targets(self) -> TernaryVector | None:
        """Return node requests with pending destinations preserved."""
        return None if self.event_update is None else self.event_update.requested_targets

    @property
    def event_potential_energy_change(self) -> float:
        """Full potential-energy change due to phase or ternary events."""
        return (
            self.energy_after_events.energy.total_energy
            - self.energy_before_events.energy.total_energy
        )

    @property
    def mechanical_potential_energy_change(self) -> float:
        """Full potential-energy change due to the mechanical interval."""
        return (
            self.energy_after_mechanics.energy.total_energy
            - self.energy_after_events.energy.total_energy
        )


def execute_rank_two_coupled_md_step(
    state: CoupledMolecularDynamicsState,
    *,
    model: RankTwoConservativeEnergyModel,
    force_evaluator: RankTwoConservativeForceEvaluator,
    features: ScalarVectorTensorFeatures,
    cutoff: float,
    phase_parameters: PhaseDynamicsParameters | None = None,
    phase_time_step: float | None = None,
    ternary_event: bool = False,
    projection: ResonanceProjection | None = None,
    thresholds: TernaryTargetThresholds | None = None,
    guards: tuple[TernaryExecutionGuard, ...] | None = None,
    mechanical_time_step: float | None = None,
) -> RankTwoCoupledMolecularDynamicsStep:
    """Execute phase, retained-ternary, and tensor-force MD clocks in order.

    The existing coupled executor advances the phase and ternary clocks.
    The rank-two mechanical integrator then uses the full-energy forces at
    both endpoints while holding the post-event features and execution fixed.
    """
    if not isinstance(state, CoupledMolecularDynamicsState):
        raise TypeError("state must be CoupledMolecularDynamicsState.")
    if not isinstance(model, RankTwoConservativeEnergyModel):
        raise TypeError("model must be RankTwoConservativeEnergyModel.")
    if not isinstance(force_evaluator, RankTwoConservativeForceEvaluator):
        raise TypeError("force_evaluator must be RankTwoConservativeForceEvaluator.")
    if not isinstance(features, ScalarVectorTensorFeatures):
        raise TypeError("features must be ScalarVectorTensorFeatures.")
    if features.node_count != state.md_state.atom_count:
        raise ValueError("feature nodes must match mechanical atom count.")
    if not isinstance(ternary_event, bool):
        raise TypeError("ternary_event must be bool.")
    checked_cutoff = _positive_real(cutoff, "cutoff")
    if mechanical_time_step is not None:
        mechanical_time_step = _positive_real(mechanical_time_step, "mechanical_time_step")
    if phase_time_step is None and phase_parameters is not None:
        raise ValueError("phase_parameters require phase_time_step.")
    if not ternary_event and any(x is not None for x in (projection, thresholds, guards)):
        raise ValueError("projection, thresholds, and guards require a ternary event.")
    if phase_time_step is None and not ternary_event and mechanical_time_step is None:
        raise ValueError("at least one phase, ternary, or mechanical operation is required.")
    if model.reference_model.energy_functional.scalar_channel_count != (
        features.base.scalar_channel_count + 2
    ):
        raise ValueError("reference energy requires base scalars plus two resonance channels.")

    before_descriptor = resonance_descriptor(state.resonance_state)
    before_features = _resonance_features(features, before_descriptor)
    graph = build_cutoff_graph(state.md_state.configuration, checked_cutoff)
    energy_before = model.evaluate(
        state.md_state.configuration, graph, before_features, state.ternary_execution,
    )

    event_update: CoupledMolecularDynamicsStep | None = None
    event_state = state
    if phase_time_step is not None or ternary_event:
        event_update = execute_coupled_md_step(
            state,
            model=model.reference_model,
            force_evaluator=ConservativeForceEvaluator(force_evaluator.differentiation),
            base_features=features.base,
            cutoff=checked_cutoff,
            phase_parameters=phase_parameters,
            phase_time_step=phase_time_step,
            ternary_event=ternary_event,
            projection=projection,
            thresholds=thresholds,
            guards=guards,
        )
        event_state = event_update.current

    descriptor = resonance_descriptor(event_state.resonance_state)
    event_features = _resonance_features(features, descriptor)
    energy_after_events = (
        model.evaluate(
            state.md_state.configuration,
            graph,
            event_features,
            event_state.ternary_execution,
        )
        if event_update is not None else energy_before
    )

    mechanical_update: MolecularDynamicsStepResult | None = None
    final_md = state.md_state
    energy_after_mechanics = energy_after_events
    if mechanical_time_step is not None:
        mechanical_update = _rank_two_verlet_step(
            state.md_state,
            model,
            force_evaluator,
            event_features,
            event_state.ternary_execution,
            checked_cutoff,
            mechanical_time_step,
        )
        final_md = mechanical_update.current
        energy_after_mechanics = model.evaluate(
            final_md.configuration,
            mechanical_update.graph_after,
            event_features,
            event_state.ternary_execution,
        )

    updated = CoupledMolecularDynamicsState(
        md_state=final_md,
        resonance_state=event_state.resonance_state,
        ternary_execution=event_state.ternary_execution,
        resonance_time=event_state.resonance_time,
        resonance_step_count=event_state.resonance_step_count,
        ternary_event_count=event_state.ternary_event_count,
    )
    return RankTwoCoupledMolecularDynamicsStep(
        previous=state,
        current=updated,
        event_update=event_update,
        mechanical_update=mechanical_update,
        descriptor=descriptor,
        features_before_events=before_features,
        features_after_events=event_features,
        energy_before_events=energy_before,
        energy_after_events=energy_after_events,
        energy_after_mechanics=energy_after_mechanics,
    )

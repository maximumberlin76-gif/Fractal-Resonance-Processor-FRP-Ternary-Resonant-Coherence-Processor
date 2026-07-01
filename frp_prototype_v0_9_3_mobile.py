#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# FRP · Fractal Resonance Processor Prototype
# v0.9.3-mobile · single-file working prototype
# License: Apache-2.0

import argparse
import json
import math
from collections import defaultdict
from dataclasses import dataclass, asdict

import numpy as np

TAU = 2 * np.pi
TRITS = np.array([-1, 0, 1], dtype=np.int8)


def trits(v, name="v", N=None):
    v = np.asarray(v, dtype=np.int8)

    if N is not None and v.size != N:
        raise ValueError(f"{name} size mismatch: expected {N}, got {v.size}")

    if not np.all(np.isin(v, TRITS)):
        raise ValueError(f"{name} must contain only -1, 0, 1")

    return v


def rand_trits(rng, N):
    return rng.choice(
        TRITS,
        size=int(N),
        p=[0.35, 0.30, 0.35],
    ).astype(np.int8)


def q(x, tau=0.33):
    y = np.zeros_like(x, dtype=np.int8)
    y[x >= tau] = 1
    y[x <= -tau] = -1
    return y


def qW(W, tau=0.25):
    Q = np.zeros_like(W, dtype=np.int8)
    Q[W >= tau] = 1
    Q[W <= -tau] = -1
    return Q


def phase_from_trits(s):
    s = trits(s, "s")

    p = np.full(s.shape, np.pi / 2.0, dtype=float)
    p[s == 1] = 0.0
    p[s == -1] = np.pi

    return p


def cubic_saturation(x, beta=0.75):
    return x / (1.0 + beta * np.abs(x) ** 3)


def nonlinear_channel(x, beta=0.75, gain=1.20):
    return np.tanh(gain * cubic_saturation(x, beta=beta))


def normalize_trit(x):
    x = int(x)
    carry = 0

    while x > 1:
        x -= 3
        carry += 1

    while x < -1:
        x += 3
        carry -= 1

    return np.int8(x), int(carry)


def t_neg(a):
    return (-trits(a, "a")).astype(np.int8)


def t_add(a, b):
    a = trits(a, "a")
    b = trits(b, "b")

    if a.size != b.size:
        raise ValueError("a and b size mismatch")

    out = np.zeros_like(a, dtype=np.int8)
    carry = 0

    for i in range(a.size):
        out[i], carry = normalize_trit(int(a[i]) + int(b[i]) + carry)
        carry = max(-1, min(1, carry))

    return out, np.int8(carry if carry in (-1, 0, 1) else np.sign(carry))


def t_sub(a, b):
    return t_add(a, t_neg(b))


def t_value(a):
    a = trits(a, "a")

    value = 0
    power = 1

    for d in a:
        value += int(d) * power
        power *= 3

    return int(value)


def t_compare(a, b):
    av = t_value(a)
    bv = t_value(b)

    return np.int8(1 if av > bv else -1 if av < bv else 0)


def t_consensus(a, b):
    a = trits(a, "a")
    b = trits(b, "b")

    if a.size != b.size:
        raise ValueError("a and b size mismatch")

    out = np.zeros_like(a, dtype=np.int8)

    same = a == b
    out[same] = a[same]

    out[(a != 0) & (b == 0)] = a[(a != 0) & (b == 0)]
    out[(a == 0) & (b != 0)] = b[(a == 0) & (b != 0)]
    out[(a * b) == -1] = 0

    return out


def target_for(op, a, b=None):
    op = op.lower()
    a = trits(a, "a")

    if op == "neg":
        return t_neg(a), 0, None

    if b is None:
        raise ValueError(f"operation {op} requires b")

    b = trits(b, "b")

    if op == "add":
        out, ov = t_add(a, b)
        return out, int(ov), None

    if op == "sub":
        out, ov = t_sub(a, b)
        return out, int(ov), None

    if op == "compare":
        c = int(t_compare(a, b))
        out = np.zeros_like(a, dtype=np.int8)
        out[0] = c
        return out, 0, c

    if op == "consensus":
        return t_consensus(a, b), 0, None

    raise ValueError(f"unknown operation: {op}")


def expected_scheduler_counts(mode, steps):
    commits = 0
    excites = 0
    balances = 0
    neutralizes = 0

    for tick in range(int(steps)):
        local = tick % 8

        if mode == "free":
            commits += 1

        elif mode == "7/1":
            if local < 7:
                balances += 1
            else:
                commits += 1

        elif mode == "1/7":
            if local == 0:
                excites += 1
            else:
                neutralizes += 1

        else:
            raise ValueError(f"unknown cycle mode: {mode}")

    return commits, excites, balances, neutralizes


class FRPCore:
    def __init__(
        self,
        N=32,
        seed=42,
        cycle_mode="7/1",
        dt=5e-3,
        k_global=0.6,
        sigma=0.03,
        gamma=np.pi * 0.3,
        state_tau=0.33,
        logic_tau=0.20,
        wq_tau=0.25,
        phase_kick=0.15,
        neutral_min_hold=2,
        max_hold=120,
        refractory=20,
        heat_limit=1.50,
        saturation_beta=0.75,
        compression_gain=1.20,
        delay_ticks=3,
        logic_delay_ticks=None,
        coupling_delay_ticks=None,
        transition_fraction=0.25,
        telemetry_every=1,
    ):
        self.N = int(N)

        if self.N < 1:
            raise ValueError("N must be >= 1")

        if cycle_mode not in ("free", "7/1", "1/7"):
            raise ValueError("cycle_mode must be free, 7/1, or 1/7")

        if int(telemetry_every) != 1:
            raise ValueError("per-tick telemetry is mandatory: telemetry_every must be 1")

        self.rng = np.random.default_rng(seed)
        self.cycle_mode = cycle_mode

        self.dt = float(dt)
        self.kg = float(k_global)
        self.sigma = float(sigma)
        self.gamma = float(gamma)

        self.state_tau = float(state_tau)
        self.logic_tau = float(logic_tau)
        self.phase_kick = float(phase_kick)

        self.neutral_min_hold = int(neutral_min_hold)
        self.max_hold = int(max_hold)
        self.refractory = int(refractory)

        self.heat_limit = float(heat_limit)
        self.saturation_beta = float(saturation_beta)
        self.compression_gain = float(compression_gain)

        self.logic_delay_ticks = max(
            1,
            int(logic_delay_ticks if logic_delay_ticks is not None else delay_ticks),
        )

        self.coupling_delay_ticks = max(
            1,
            int(coupling_delay_ticks if coupling_delay_ticks is not None else delay_ticks),
        )

        self.transition_fraction = min(
            1.0,
            max(1.0 / self.N, float(transition_fraction)),
        )

        W = self.rng.normal(0.0, 1.0, (self.N, self.N))
        W = (W + W.T) / 2.0
        np.fill_diagonal(W, 0.0)
        W /= np.max(np.abs(W)) + 1e-12

        self.W = W
        self.Wq = qW(W, tau=wq_tau)

        self.omega = self.rng.normal(TAU, TAU * 0.10, self.N)
        self.theta = self.rng.uniform(0.0, TAU, self.N)
        self.s = q(np.cos(self.theta), tau=self.state_tau)

        self.ext_freq = TAU * np.ones(self.N)
        self.ext_amp = np.zeros(self.N)
        self.ext_phase = np.zeros(self.N)

        self.target = None

        self.logic_delay = np.zeros((self.logic_delay_ticks + 1, self.N), dtype=float)
        self.coupling_delay = np.zeros((self.coupling_delay_ticks + 1, self.N), dtype=float)

        self.logic_delay_index = 0
        self.coupling_delay_index = 0

        self.hold = np.zeros(self.N, dtype=np.int16)
        self.neutral_hold = np.zeros(self.N, dtype=np.int16)
        self.refractory_timer = np.zeros(self.N, dtype=np.int16)

        self.node_heat = np.zeros(self.N, dtype=float)

        self.heat = 0.0
        self.thermal_scale = 1.0
        self.switch_load = 0.0

        self.tick = 0
        self.last_phase = "init"

        self.commit_count = 0
        self.excite_count = 0
        self.balance_count = 0
        self.neutralize_count = 0

        self.actual_direct_events = 0
        self.prevented_direct_events = 0
        self.neutralized_conflicts = 0

        self.actual_direct_delta = 0
        self.prevented_direct_delta = 0
        self.neutralized_delta = 0

        self.telemetry = []

    def reset_operation(self):
        self.tick = 0
        self.last_phase = "init"

        self.commit_count = 0
        self.excite_count = 0
        self.balance_count = 0
        self.neutralize_count = 0

        self.actual_direct_events = 0
        self.prevented_direct_events = 0
        self.neutralized_conflicts = 0

        self.actual_direct_delta = 0
        self.prevented_direct_delta = 0
        self.neutralized_delta = 0

        self.node_heat[:] = 0.0

        self.heat = 0.0
        self.thermal_scale = 1.0
        self.switch_load = 0.0

        self.hold[:] = 0
        self.neutral_hold[:] = 0
        self.refractory_timer[:] = 0

        self.logic_delay[:] = 0.0
        self.coupling_delay[:] = 0.0

        self.logic_delay_index = 0
        self.coupling_delay_index = 0

        self.telemetry = []

    def cycle_gate(self):
        if self.cycle_mode == "free":
            return "commit", True, 1.00, 1.00, False

        local = self.tick % 8

        if self.cycle_mode == "7/1":
            if local < 7:
                return "balance", False, 0.45, 0.35, False
            return "commit", True, 1.00, 1.00, False

        if local == 0:
            return "excite", True, 1.00, 1.00, False

        return "neutralize", False, 0.25, 0.00, True

    def delay(self, which, x):
        if which == "logic":
            buf = self.logic_delay
            idx = self.logic_delay_index

        elif which == "coupling":
            buf = self.coupling_delay
            idx = self.coupling_delay_index

        else:
            raise ValueError("unknown delay buffer")

        buf[idx] = x
        return buf[(idx + 1) % len(buf)].copy()

    def advance_delays(self):
        self.logic_delay_index = (self.logic_delay_index + 1) % len(self.logic_delay)
        self.coupling_delay_index = (self.coupling_delay_index + 1) % len(self.coupling_delay)

    def shape(self, x):
        return nonlinear_channel(
            x,
            beta=self.saturation_beta,
            gain=self.compression_gain,
        )

    def select(self, mask):
        idx = np.flatnonzero(mask)
        selected = np.zeros(self.N, dtype=bool)

        if idx.size:
            limit = max(1, int(math.ceil(self.transition_fraction * self.N)))
            selected[idx[: min(limit, idx.size)]] = True

        return selected

    def encode(self, a, amp=0.30):
        a = trits(a, "input", self.N)
        phase = phase_from_trits(a)

        self.theta = phase.copy()
        self.s = a.copy()
        self.ext_phase = phase.copy()
        self.ext_amp = float(amp) * np.ones(self.N)

        self.target = None

        self.logic_delay[:] = 0.0
        self.coupling_delay[:] = 0.0

        self.logic_delay_index = 0
        self.coupling_delay_index = 0

        self.hold[:] = 0
        self.neutral_hold[:] = 0
        self.refractory_timer[:] = 0

    def set_target(self, target, amp=0.30):
        target = trits(target, "target", self.N)

        self.target = target.copy()
        self.ext_phase = phase_from_trits(target)
        self.ext_amp = float(amp) * np.ones(self.N)

    def order(self):
        z = np.exp(1j * self.theta)
        m = np.mean(z)

        return float(np.abs(m)), float(np.angle(m))

    def local_logic(self):
        deg = np.maximum(np.sum(np.abs(self.Wq), axis=1), 1)
        raw = (self.Wq @ self.s) / deg

        return q(
            self.delay("logic", self.shape(raw)),
            tau=self.logic_tau,
        )

    def phase_logic(self):
        shaped = self.shape(np.cos(self.theta))
        next_state = self.s.copy()

        enter = self.state_tau + 0.05
        exit_level = max(self.state_tau - 0.05, 0.0)

        zero = self.s == 0

        next_state[zero & (shaped >= enter)] = 1
        next_state[zero & (shaped <= -enter)] = -1

        next_state[(next_state == 1) & (shaped < exit_level)] = 0
        next_state[(next_state == -1) & (shaped > -exit_level)] = 0

        return next_state.astype(np.int8)

    def free_proposal(self):
        p = self.phase_logic()
        l = self.local_logic()

        out = np.zeros(self.N, dtype=np.int8)

        same = (p == l) & (p != 0)
        phase_only = (p != 0) & (l == 0)
        logic_only = (p == 0) & (l != 0)
        conflict = (p * l) == -1

        out[same] = p[same]
        out[phase_only] = p[phase_only]
        out[logic_only] = l[logic_only]
        out[conflict] = 0

        return out, conflict

    def target_proposal(self, allow_commit):
        prev = self.s
        target = self.target
        out = prev.copy()

        direct = (prev * target) == -1

        release = self.select((prev != 0) & (prev != target))
        out[release] = 0

        can_activate = (
            allow_commit
            & (prev == 0)
            & (target != 0)
            & (self.neutral_hold >= self.neutral_min_hold)
            & (self.refractory_timer <= 0)
        )

        if np.any(can_activate):
            activate = self.select(can_activate)
            out[activate] = target[activate]

        return out.astype(np.int8), direct

    def update_ternary(self, allow_commit, neutral_bias):
        prev = self.s.copy()

        if self.target is None:
            proposed, conflict = self.free_proposal()
            direct = (prev * proposed) == -1

            proposed[direct] = 0

            if not allow_commit:
                proposed[(prev == 0) & (proposed != 0)] = 0

            proposed[
                (prev == 0)
                & (proposed != 0)
                & (self.neutral_hold < self.neutral_min_hold)
            ] = 0

        else:
            proposed, direct = self.target_proposal(allow_commit)
            conflict = np.zeros(self.N, dtype=bool)

        self.prevented_direct_delta = int(np.count_nonzero(direct))

        if neutral_bias:
            proposed[conflict | direct] = 0
            proposed[self.node_heat > 0.5 * self.heat_limit] = 0

        refractory = self.refractory_timer > 0

        proposed[refractory] = 0
        self.refractory_timer[refractory] -= 1

        if self.target is not None:
            proposed[
                (prev == 0)
                & (proposed != 0)
                & (self.neutral_hold < self.neutral_min_hold)
            ] = 0

        neutralized_mask = direct & (prev != 0) & (proposed == 0)
        self.neutralized_delta = int(np.count_nonzero(neutralized_mask))

        held = (proposed == prev) & (proposed != 0)

        self.hold[held] += 1
        self.hold[~held] = 0

        stuck = (self.hold >= self.max_hold) & (proposed != 0)

        if self.target is not None:
            stuck &= ~((proposed == self.target) & (proposed != 0))

        hot = self.node_heat >= self.heat_limit
        reset = stuck | hot

        proposed[reset] = 0
        self.refractory_timer[reset] = self.refractory
        self.hold[reset] = 0

        change = proposed != prev
        idx = np.flatnonzero(change)

        max_changes = max(1, int(math.ceil(self.transition_fraction * self.N)))

        if idx.size > max_changes:
            keep = np.zeros(self.N, dtype=bool)
            keep[idx[:max_changes]] = True
            proposed[change & ~keep] = prev[change & ~keep]

        switched = proposed != prev
        active = proposed != 0
        neutral = proposed == 0
        actual_direct = (prev * proposed) == -1

        self.node_heat += 0.020 * switched.astype(float)
        self.node_heat += 0.001 * active.astype(float)
        self.node_heat += 0.030 * (conflict | direct).astype(float)
        self.node_heat -= 0.010 * neutral.astype(float)
        self.node_heat -= 0.003
        self.node_heat = np.maximum(self.node_heat, 0.0)

        self.s = proposed.astype(np.int8)

        self.switch_load = float(np.mean(switched))
        self.heat = float(np.mean(self.node_heat))
        self.thermal_scale = max(
            0.15,
            1.0 - max(0.0, self.heat - 1.0) / 0.5,
        )

        self.actual_direct_delta = int(np.count_nonzero(actual_direct))
        self.actual_direct_events += self.actual_direct_delta

        self.prevented_direct_events += self.prevented_direct_delta
        self.neutralized_conflicts += self.neutralized_delta

        self.neutral_hold[neutral] += 1
        self.neutral_hold[~neutral] = 0

    def dtheta(self, theta, amp_now):
        diff = theta[:, None] - theta[None, :]
        raw = np.sum(self.W * np.sin(-diff - self.gamma), axis=1)
        coupling = self.delay("coupling", self.shape(raw))
        pll = amp_now * np.sin(self.ext_phase - theta)

        return self.omega + self.kg * coupling + pll

    def stability(self):
        R, _ = self.order()
        neutral = float(np.mean(self.s == 0))

        if self.target is None:
            match = 0.0
            debt = 0.0
            conflict = 0.0
            C = R * (1.0 - 0.35 * neutral)

        else:
            match = float(np.mean(self.s == self.target))
            debt = float(np.mean(self.s != self.target))
            conflict = float(np.mean((self.s * self.target) == -1))

            hot = float(np.mean(self.node_heat > 0.5 * self.heat_limit))
            refr = float(np.mean(self.refractory_timer > 0))

            C = max(
                0.0,
                min(
                    1.0,
                    1.0
                    - 0.50 * conflict
                    - 0.20 * debt
                    - 0.10 * hot
                    - 0.10 * refr,
                ),
            )

        P = self.heat + self.switch_load

        return C, P, C - P, R, match, debt, conflict

    def record(self):
        C, P, CP, R, match, debt, conflict = self.stability()
        _, phi = self.order()

        self.telemetry.append(
            {
                "tick": int(self.tick),
                "phase": self.last_phase,
                "R": float(R),
                "phi": float(phi),
                "neutral": float(np.mean(self.s == 0)),
                "positive": float(np.mean(self.s == 1)),
                "negative": float(np.mean(self.s == -1)),
                "heat": float(self.heat),
                "thermal_scale": float(self.thermal_scale),
                "switch_load": float(self.switch_load),
                "actual_direct_events_delta": int(self.actual_direct_delta),
                "prevented_direct_events_delta": int(self.prevented_direct_delta),
                "neutralized_conflicts_delta": int(self.neutralized_delta),
                "logical_match": float(match),
                "transition_debt": float(debt),
                "direct_conflict_fraction": float(conflict),
                "C": float(C),
                "P": float(P),
                "C_minus_P": float(CP),
            }
        )

    def summary(self):
        if not self.telemetry:
            return {}

        def a(k):
            return np.array([x[k] for x in self.telemetry], dtype=float)

        return {
            "ticks_recorded": len(self.telemetry),
            "C_minus_P_min": float(np.min(a("C_minus_P"))),
            "C_minus_P_avg": float(np.mean(a("C_minus_P"))),
            "heat_peak": float(np.max(a("heat"))),
            "heat_avg": float(np.mean(a("heat"))),
            "switch_load_peak": float(np.max(a("switch_load"))),
            "switch_load_avg": float(np.mean(a("switch_load"))),
            "neutral_peak": float(np.max(a("neutral"))),
            "neutral_avg": float(np.mean(a("neutral"))),
            "logical_match_final": float(a("logical_match")[-1]),
            "logical_match_avg": float(np.mean(a("logical_match"))),
            "actual_direct_events_total": int(np.sum(a("actual_direct_events_delta"))),
            "prevented_direct_events_total": int(np.sum(a("prevented_direct_events_delta"))),
            "neutralized_conflicts_total": int(np.sum(a("neutralized_conflicts_delta"))),
        }

    def step(self, n=1):
        for _ in range(int(n)):
            phase, allow, amp_scale, kick_scale, neutral_bias = self.cycle_gate()

            self.last_phase = phase

            self.commit_count += phase == "commit"
            self.excite_count += phase == "excite"
            self.balance_count += phase == "balance"
            self.neutralize_count += phase == "neutralize"

            logic = self.target if self.target is not None else self.local_logic()

            self.ext_phase = (
                self.ext_phase
                + self.dt * self.ext_freq
                + self.phase_kick * kick_scale * logic.astype(float)
            ) % TAU

            amp_now = self.ext_amp * amp_scale * self.thermal_scale

            k1 = self.dtheta(self.theta, amp_now)
            k2 = self.dtheta((self.theta + self.dt * k1) % TAU, amp_now)

            self.theta = (
                self.theta
                + self.dt * 0.5 * (k1 + k2)
                + self.sigma * self.rng.normal(0.0, 1.0, self.N)
            ) % TAU

            self.update_ternary(
                allow_commit=allow,
                neutral_bias=neutral_bias,
            )

            self.advance_delays()

            self.tick += 1
            self.record()

    def compute(self, op, a, b=None, steps=128, amp=0.30):
        self.reset_operation()

        a = trits(a, "a", self.N)
        target, overflow, compare = target_for(op, a, b)

        self.encode(a, amp=amp)
        self.set_target(target, amp=amp)

        self.step(steps)

        C, P, CP, R, match, _, _ = self.stability()

        output = self.s.copy()

        return {
            "op": op,
            "target": target,
            "output": output,
            "overflow": int(overflow),
            "compare": compare,
            "match": float(np.mean(output == target)),
            "summary": self.summary(),
            "diag": {
                "C": C,
                "P": P,
                "C_minus_P": CP,
                "R": R,
                "logical_match": match,
                "actual_direct_events": int(self.actual_direct_events),
                "prevented_direct_events": int(self.prevented_direct_events),
                "neutralized_conflicts": int(self.neutralized_conflicts),
                "commits": int(self.commit_count),
                "excites": int(self.excite_count),
                "balances": int(self.balance_count),
                "neutralizes": int(self.neutralize_count),
            },
        }


@dataclass
class Instruction:
    op: str
    dst: str = ""
    src_a: str = ""
    src_b: str = ""
    imm: list = None
    comment: str = ""


class RegisterFile:
    def __init__(self, N, count=8):
        self.N = int(N)
        self.regs = {
            f"R{i}": np.zeros(self.N, dtype=np.int8)
            for i in range(count)
        }

    def read(self, name):
        if name not in self.regs:
            raise ValueError(f"unknown register: {name}")

        return self.regs[name].copy()

    def write(self, name, value):
        if name not in self.regs:
            raise ValueError(f"unknown register: {name}")

        self.regs[name] = trits(value, name, self.N).copy()

    def snapshot(self, limit=16):
        return {
            k: v[:limit].astype(int).tolist()
            for k, v in self.regs.items()
        }


class FRPProcessor:
    def __init__(
        self,
        N=32,
        seed=42,
        registers=8,
        steps=128,
        amp=0.30,
        **core_kwargs,
    ):
        self.N = int(N)
        self.steps = int(steps)
        self.amp = float(amp)

        self.rng = np.random.default_rng(seed)
        self.rf = RegisterFile(N, registers)

        self.core_kwargs = {
            "N": self.N,
            "seed": seed,
            **core_kwargs,
        }

        self.log = []
        self.pc = 0
        self.halted = False

    def run(self, program, stop_on_fail=True):
        self.log = []
        self.pc = 0
        self.halted = False

        while self.pc < len(program) and not self.halted:
            row = self.exec(program[self.pc])
            self.log.append(row)

            if row["status"] == "FAIL" and stop_on_fail:
                break

            self.pc += 1

        return self.log

    def exec(self, ins):
        op = ins.op.lower()

        row = {
            "pc": self.pc,
            "instruction": asdict(ins),
            "status": "OK",
            "failures": [],
            "result": None,
        }

        if op == "halt":
            self.halted = True
            row["status"] = "HALT"
            return row

        if op == "load":
            self.rf.write(ins.dst, np.array(ins.imm, dtype=np.int8))
            return row

        if op == "rand":
            self.rf.write(ins.dst, rand_trits(self.rng, self.N))
            return row

        if op == "zero":
            self.rf.write(ins.dst, np.zeros(self.N, dtype=np.int8))
            return row

        if op == "mov":
            self.rf.write(ins.dst, self.rf.read(ins.src_a))
            return row

        if op not in ("neg", "add", "sub", "compare", "consensus"):
            raise ValueError(f"unknown instruction: {op}")

        core = FRPCore(**self.core_kwargs)

        a = self.rf.read(ins.src_a)
        b = None if op == "neg" else self.rf.read(ins.src_b)

        result = core.compute(
            op,
            a,
            b,
            steps=self.steps,
            amp=self.amp,
        )

        self.rf.write(ins.dst, result["output"])

        s = result["summary"]
        row["result"] = result

        if result["match"] < 1.0:
            row["failures"].append("match < 1.0")

        if s["actual_direct_events_total"] != 0:
            row["failures"].append("actual direct event")

        if s["C_minus_P_min"] <= 0.0:
            row["failures"].append("C-P <= 0")

        if s["ticks_recorded"] != self.steps:
            row["failures"].append(
                f"telemetry tick mismatch: {s['ticks_recorded']} vs {self.steps}"
            )

        expected = expected_scheduler_counts(core.cycle_mode, self.steps)

        got = (
            result["diag"]["commits"],
            result["diag"]["excites"],
            result["diag"]["balances"],
            result["diag"]["neutralizes"],
        )

        if got != expected:
            row["failures"].append(
                f"scheduler mismatch: got {got}, expected {expected}"
            )

        if row["failures"]:
            row["status"] = "FAIL"

        return row

    def report(self):
        return {
            "instructions_executed": len(self.log),
            "failures": sum(1 for x in self.log if x["status"] == "FAIL"),
            "halted": self.halted,
            "registers": self.rf.snapshot(),
        }


def demo_program(N, rng):
    a = rand_trits(rng, N).astype(int).tolist()
    b = rand_trits(rng, N).astype(int).tolist()

    return [
        Instruction("load", "R1", imm=a),
        Instruction("load", "R2", imm=b),
        Instruction("add", "R3", "R1", "R2"),
        Instruction("sub", "R4", "R1", "R2"),
        Instruction("neg", "R5", "R1"),
        Instruction("compare", "R6", "R1", "R2"),
        Instruction("consensus", "R7", "R1", "R2"),
        Instruction("halt"),
    ]


def direct_baseline(a, target):
    a = trits(a)
    target = trits(target)

    switched = target != a
    direct = (a * target) == -1

    heat = (
        0.020 * float(np.mean(switched))
        + 0.030 * float(np.mean(direct))
        + 0.001 * float(np.mean(target != 0))
    )

    C = 1.0 - 0.50 * float(np.mean(direct))
    P = heat + float(np.mean(switched))

    return {
        "match": 1.0,
        "C_minus_P_min": float(C - P),
        "heat_peak": float(heat),
        "switch_load_peak": float(np.mean(switched)),
        "actual_direct_events_total": int(np.count_nonzero(direct)),
        "neutralized_conflicts_total": 0,
    }


def distributed_neutral_baseline(a, target, fraction=0.25):
    state = trits(a).copy()
    target = trits(target)

    limit = max(1, int(math.ceil(fraction * state.size)))

    heat = 0.0
    trace = []

    def tick(prev, state, neutralized=0):
        nonlocal heat

        switched = state != prev
        neutral = state == 0

        heat += 0.020 * float(np.mean(switched))
        heat += 0.001 * float(np.mean(state != 0))
        heat -= 0.010 * float(np.mean(neutral))
        heat -= 0.003
        heat = max(0.0, heat)

        debt = float(np.mean(state != target))
        conflict = float(np.mean((state * target) == -1))

        C = max(
            0.0,
            min(
                1.0,
                1.0 - 0.20 * debt - 0.50 * conflict,
            ),
        )

        P = heat + float(np.mean(switched))

        trace.append(
            (
                C - P,
                heat,
                float(np.mean(switched)),
                neutralized,
            )
        )

    while np.any((state != target) & (state != 0)):
        prev = state.copy()

        idx = np.flatnonzero((state != target) & (state != 0))[:limit]
        neutralized = int(np.count_nonzero((prev[idx] * target[idx]) == -1))

        state[idx] = 0
        tick(prev, state, neutralized)

    while np.any((state == 0) & (target != 0)):
        prev = state.copy()

        idx = np.flatnonzero((state == 0) & (target != 0))[:limit]
        state[idx] = target[idx]

        tick(prev, state, 0)

    if not trace:
        tick(state.copy(), state, 0)

    return {
        "match": 1.0,
        "C_minus_P_min": float(min(x[0] for x in trace)),
        "heat_peak": float(max(x[1] for x in trace)),
        "switch_load_peak": float(max(x[2] for x in trace)),
        "actual_direct_events_total": 0,
        "neutralized_conflicts_total": int(sum(x[3] for x in trace)),
    }


def binary_forced_baseline(a, target):
    a = trits(a)
    target = trits(target)

    def rails(v):
        r = np.zeros((v.size, 2), dtype=np.int8)
        r[v == -1, 0] = 1
        r[v == 1, 1] = 1
        return r.reshape(-1)

    switch = float(np.mean(rails(a) != rails(target)))
    direct = (a * target) == -1

    heat = (
        0.020 * switch
        + 0.030 * float(np.mean(direct))
        + 0.001 * float(np.mean(target != 0))
    )

    C = 1.0 - 0.50 * float(np.mean(direct))
    P = heat + switch

    return {
        "match": 1.0,
        "C_minus_P_min": float(C - P),
        "heat_peak": float(heat),
        "switch_load_peak": switch,
        "actual_direct_events_total": int(np.count_nonzero(direct)),
        "neutralized_conflicts_total": 0,
    }


def run_demo(args):
    p = FRPProcessor(
        N=args.N,
        seed=args.seed,
        steps=args.steps,
        amp=args.amp,
        cycle_mode=args.cycle_mode,
        gamma=args.gamma,
        logic_delay_ticks=args.logic_delay_ticks,
        coupling_delay_ticks=args.coupling_delay_ticks,
        saturation_beta=args.saturation_beta,
        compression_gain=args.compression_gain,
        transition_fraction=args.transition_fraction,
        telemetry_every=args.telemetry_every,
    )

    log = p.run(demo_program(args.N, np.random.default_rng(args.seed)))

    print("FRP PROCESSOR DEMO v0.9.3-mobile")

    for row in log:
        print(
            f"pc={row['pc']} "
            f"op={row['instruction']['op']} "
            f"status={row['status']}"
        )

        if row["result"]:
            s = row["result"]["summary"]

            print(
                f"  match={row['result']['match']:.3f} "
                f"C-P_min={s['C_minus_P_min']:.6f} "
                f"heat_peak={s['heat_peak']:.6f} "
                f"switch_peak={s['switch_load_peak']:.6f} "
                f"actual_direct={s['actual_direct_events_total']} "
                f"prevented={s['prevented_direct_events_total']} "
                f"neutralized={s['neutralized_conflicts_total']}"
            )

        if row["failures"]:
            print("  failures=" + str(row["failures"]))

    print(
        "final_report="
        + json.dumps(
            p.report(),
            ensure_ascii=False,
            default=str,
        )
    )


def run_test(args):
    ops = ["neg", "add", "sub", "compare", "consensus"]
    modes = ["free", "7/1", "1/7"]
    Ns = [8, 16, 32, 64]

    metrics = {
        "runs": 0,
        "C_minus_P_min": 1.0,
        "heat_peak": 0.0,
        "switch_load_peak": 0.0,
        "actual_direct_events": 0,
        "prevented_direct_events": 0,
        "neutralized_conflicts": 0,
    }

    first_failure = None

    for N in Ns:
        for seed in range(args.seeds):
            for mode in modes:
                for op in ops:
                    rng = np.random.default_rng(
                        seed * 1000003 + N * 101 + len(op)
                    )

                    a = rand_trits(rng, N)
                    b = None if op == "neg" else rand_trits(rng, N)

                    core = FRPCore(
                        N=N,
                        seed=seed,
                        cycle_mode=mode,
                        gamma=args.gamma,
                        logic_delay_ticks=args.logic_delay_ticks,
                        coupling_delay_ticks=args.coupling_delay_ticks,
                        saturation_beta=args.saturation_beta,
                        compression_gain=args.compression_gain,
                        transition_fraction=args.transition_fraction,
                        telemetry_every=args.telemetry_every,
                    )

                    r = core.compute(
                        op,
                        a,
                        b,
                        steps=args.steps,
                        amp=args.amp,
                    )

                    s = r["summary"]
                    d = r["diag"]

                    metrics["runs"] += 1
                    metrics["C_minus_P_min"] = min(
                        metrics["C_minus_P_min"],
                        s["C_minus_P_min"],
                    )
                    metrics["heat_peak"] = max(
                        metrics["heat_peak"],
                        s["heat_peak"],
                    )
                    metrics["switch_load_peak"] = max(
                        metrics["switch_load_peak"],
                        s["switch_load_peak"],
                    )
                    metrics["actual_direct_events"] += s["actual_direct_events_total"]
                    metrics["prevented_direct_events"] += s["prevented_direct_events_total"]
                    metrics["neutralized_conflicts"] += s["neutralized_conflicts_total"]

                    exp = expected_scheduler_counts(mode, args.steps)

                    got = (
                        d["commits"],
                        d["excites"],
                        d["balances"],
                        d["neutralizes"],
                    )

                    fail = []

                    if r["match"] < 1.0:
                        fail.append("match < 1.0")

                    if s["actual_direct_events_total"] != 0:
                        fail.append("actual direct event")

                    if s["C_minus_P_min"] <= 0.0:
                        fail.append("C-P <= 0")

                    if s["ticks_recorded"] != args.steps:
                        fail.append(
                            f"tick mismatch: {s['ticks_recorded']} vs {args.steps}"
                        )

                    if got != exp:
                        fail.append(
                            f"scheduler mismatch: got {got}, expected {exp}"
                        )

                    if fail and first_failure is None:
                        first_failure = {
                            "N": N,
                            "seed": seed,
                            "mode": mode,
                            "op": op,
                            "fail": fail,
                            "summary": s,
                            "diag": d,
                        }

                        if args.stop_on_fail:
                            break

                if first_failure and args.stop_on_fail:
                    break

            if first_failure and args.stop_on_fail:
                break

        if first_failure and args.stop_on_fail:
            break

    print("FRP SELF TEST v0.9.3-mobile")
    print(json.dumps(metrics, ensure_ascii=False, indent=2))
    print("failures=" + ("1" if first_failure else "0"))

    if first_failure:
        print(json.dumps(first_failure, ensure_ascii=False, indent=2, default=str))
        return 1

    print("result=PASS")
    return 0


def run_bench(args):
    ops = ["neg", "add", "sub", "compare", "consensus"]
    modes = ["free", "7/1", "1/7"]
    Ns = [8, 16, 32, 64]

    groups = defaultdict(list)

    for N in Ns:
        for seed in range(args.seeds):
            for mode in modes:
                for op in ops:
                    rng = np.random.default_rng(
                        seed * 1000003 + N * 101 + len(op)
                    )

                    a = rand_trits(rng, N)
                    b = None if op == "neg" else rand_trits(rng, N)

                    target, _, _ = target_for(op, a, b)

                    core = FRPCore(
                        N=N,
                        seed=seed,
                        cycle_mode=mode,
                        gamma=args.gamma,
                        logic_delay_ticks=args.logic_delay_ticks,
                        coupling_delay_ticks=args.coupling_delay_ticks,
                        saturation_beta=args.saturation_beta,
                        compression_gain=args.compression_gain,
                        transition_fraction=args.transition_fraction,
                        telemetry_every=args.telemetry_every,
                    )

                    r = core.compute(
                        op,
                        a,
                        b,
                        steps=args.steps,
                        amp=args.amp,
                    )

                    groups["frp_distributed_resonant"].append(
                        r["summary"] | {"match": r["match"]}
                    )
                    groups["direct_ternary_commit"].append(
                        direct_baseline(a, target)
                    )
                    groups["distributed_neutral_ternary"].append(
                        distributed_neutral_baseline(
                            a,
                            target,
                            args.transition_fraction,
                        )
                    )
                    groups["binary_style_forced_switch"].append(
                        binary_forced_baseline(a, target)
                    )

    print("FRP BENCHMARK v0.9.3-mobile")
    print(
        "arch | cases | match | C-P_min | heat_peak | switch_peak | "
        "actual_direct | prevented_direct | neutralized"
    )
    print("-" * 150)

    for arch, rows in sorted(groups.items()):
        cases = len(rows)
        match = min(
            float(x.get("match", x.get("logical_match_final", 1.0)))
            for x in rows
        )
        cp = min(float(x["C_minus_P_min"]) for x in rows)
        heat = max(float(x["heat_peak"]) for x in rows)
        sw = max(float(x["switch_load_peak"]) for x in rows)

        actual = sum(int(x.get("actual_direct_events_total", 0)) for x in rows)
        prevented = sum(int(x.get("prevented_direct_events_total", 0)) for x in rows)
        neutralized = sum(int(x.get("neutralized_conflicts_total", 0)) for x in rows)

        print(
            f"{arch} | {cases} | {match:.3f} | {cp:.6f} | "
            f"{heat:.6f} | {sw:.6f} | {actual} | {prevented} | {neutralized}"
        )


def parse_args():
    p = argparse.ArgumentParser(
        description="FRP v0.9.3-mobile single-file prototype"
    )

    p.add_argument("--mode", choices=["demo", "test", "bench"], default="demo")
    p.add_argument("--N", type=int, default=32)
    p.add_argument("--steps", type=int, default=128)
    p.add_argument("--seeds", type=int, default=5)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--amp", type=float, default=0.30)
    p.add_argument("--cycle-mode", choices=["free", "7/1", "1/7"], default="7/1")
    p.add_argument("--gamma", type=float, default=np.pi * 0.3)
    p.add_argument("--logic-delay-ticks", type=int, default=None)
    p.add_argument("--coupling-delay-ticks", type=int, default=None)
    p.add_argument("--saturation-beta", type=float, default=0.75)
    p.add_argument("--compression-gain", type=float, default=1.20)
    p.add_argument("--transition-fraction", type=float, default=0.25)
    p.add_argument("--telemetry-every", type=int, default=1)
    p.add_argument("--stop-on-fail", action="store_true")

    return p.parse_args()


def main():
    args = parse_args()

    if args.mode == "demo":
        run_demo(args)
        return 0

    if args.mode == "test":
        return run_test(args)

    if args.mode == "bench":
        run_bench(args)
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())

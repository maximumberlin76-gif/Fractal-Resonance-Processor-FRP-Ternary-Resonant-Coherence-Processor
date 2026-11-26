# FRP in one page

**Fractal Resonance Processor · v3.4.0-rc.2 · Maksym Marnov (Alchimist), Berlin · Apache-2.0**  
[Release DOI](https://doi.org/10.5281/zenodo.24392460)

## Phase dynamics and active-zero execution

FRP couples resonant phase dynamics to a balanced ternary execution layer. Local phase and frequency evolve through Kuramoto–Sakaguchi interaction, hierarchical fractal coupling, asymmetric phase lag and retained frequency memory. Relative-phase interference and resonant selection produce a target. The execution layer registers that target and determines when the cell can change its retained state.

The retained states are `−1`, `0` and `+1`. A cell reverses polarity through `−1 → 0 → +1` or `+1 → 0 → −1`. The two legs execute on separate ticks. During mediation the cell can retain `0` while the pending route preserves its destination. The temporal modes are `7/1` and `1/7`. The separate service mode is `free`. [Architecture and execution](../README.md)

## One cell, two route legs

In the published eight-cell M32 test, the testbench loads phase word `0xC0000000` into cell 0 before source tick 8. Its Q30 projection represents exactly −1. The table follows this cell in mode `7/1`. The monitor samples both targets before the execution edge and the retained state and pending destination after it.

| Source tick | Phase-derived target | Registered target | Retained state | Pending destination |
|---|---:|---:|---:|---|
| 8 | −1 | +1 | +1 | inactive |
| 9 | −1 | −1 | 0 | −1 |
| 10–14 | −1 | −1 | 0 | −1 |
| 15 | −1 | −1 | −1 | inactive |

Across one run in each mode, the monitors emitted 396 records over 33 source ticks. Of 264 cell observations, 238 recorded active zero. Cell 0 accounts for all 12 observations with both active zero and a pending destination (ticks 9–14 in `7/1` and 10–15 in `1/7`). The traces contain zero direct opposite-polarity transitions. [M32 trace bundle](../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json)

## Evidence for v3.4.0-rc.2

- **M31 routing.** All five requested direct polarity reversals in the published workload were routed through zero. The counter for actual direct transitions remained at zero. [M31 evidence](../artifacts/m31/evidence/m31-phase-interference-active-zero-thermal-evidence.json)
- **Qualification.** Workflow 158 passed all 633 tests at revision `97fd5fa`, with zero failures, errors or skips. Workflow 157 reached all 374 outcomes in its fixed branch inventory across 27 RTL files. [Release qualification](../RELEASE_NOTES_v3_4_0_rc_2.md)
- **Thermal model.** On the historical v0.9.3 workload, modeled `heat_peak` was 0.051 for binary-style forced switching and 0.00325 for distributed active-neutral ternary execution, a ratio of 15.69. The evidence record marks physical temperature measurement as `false`. [Thermal evidence](../artifacts/m31/evidence/m31-phase-interference-active-zero-thermal-evidence.json)

## Setun and BitNet

Brusentsov and colleagues used balanced ternary for arithmetic in Setun. FRP shares that choice of signed values and specifies how a retained cell moves between them over time. [Brusentsov and Ramil Alvarez on Setun](https://dl.ifip.org/db/conf/ifip9/sorucom2006/BrusentsovA06.pdf)

In BitNet b1.58, a zero weight removes one input's contribution to a weighted sum. In FRP, zero can be the cell's retained state while a pending destination governs a later transition. [Microsoft BitNet](https://github.com/microsoft/BitNet)

## Author’s perspective

“Do no harm, serve the common good, the author's right is inviolable.” — Maksym Marnov

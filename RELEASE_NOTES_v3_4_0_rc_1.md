# FRP v3.4.0-rc.1 — M32 RTL Qualification and Trace Interoperability

This candidate qualifies M31/M32 RTL branch coverage, post-synthesis behavior and deterministic trace exchange with FRP Trace Observatory. Qualified source revision: `461e766a64f33552c5d5389eb4eb5b15f2474b2b`.

| Qualification | Verified result |
|---|---|
| [RTL branch coverage, workflow 157](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/42797467764) | 374/374 outcomes in the fixed workflow 155 inventory across 27 RTL files. Archived counters account for 366 outcomes. Two byte-identical 64-cell replays cover the remaining eight, including four internal fault-injection cases. |
| [Candidate and historical tests, workflow 158](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/42810936386) | 633 distinct test methods passed without skips: 627 on the release candidate and six on their M21, M22, M23, M30 and M32 publication revisions. |
| [RTL and post-synthesis regression, workflow 155](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/42776472508) | M31 request-lane RTL and synthesized netlists each passed 53,304 comparisons at 9 and 64 cells. Both scheduler modes reproduced the published M32 trace in two replays each. |
| [Thermal post-synthesis, workflow 63](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/42687859249) | 26 outputs compared at 8, 16, 32 and 64 cells, totaling 328,328 comparisons per replay. |
| [FRP Trace Observatory M26](https://github.com/maximumberlin76-gif/FRP-Trace-Observatory/actions/runs/42709869404) | 691 tests passed without skips. The published eight-cell trace contains 396 monitor records over 33 ticks, 238 active-zero cell observations and zero direct opposite transitions. |

Workflow 157 ran at `adcb4c9b0badaf5767458d5142a142574827b0a3`. The only change from that revision to the qualified source revision was the addition of workflow 158.

## Evidence archive SHA-256

- Workflow 157: `d79d846c5d5aaad5cde281b5fd57fd0be155c9a929eb3bdcc41b4f207e9ca284`
- Workflow 158: `f47ae7d6ac5afea14458a13b49919630026e95be87e9056eefebd8b062165434`

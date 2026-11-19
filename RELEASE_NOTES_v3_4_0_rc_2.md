# FRP v3.4.0-rc.2 — Current-Revision Qualification and M32 Replay

Qualified source revision: `97fd5faab9934756b5d54e81f070d3b49ecee688`.

This candidate records 633 distinct test methods executed successfully from one checkout, together with deterministic M32 RTL replay in scheduler modes 7/1 and 1/7.

FRP computation uses retained relative-phase interference, resonant selection, multiscale coherence, and balanced ternary execution in the -1/0/1 domain. State 0 actively supports mediation, routing, retention, balancing, and controlled neutralization. Opposite-polarity execution follows -1 to 0 to 1 and 1 to 0 to -1.

## Current-revision qualification

[Workflow 158, run 44069652350](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/44069652350) qualifies the source revision above.

| Check | Verified result |
|---|---|
| Test methods discovered | 633 unique identifiers |
| Test methods executed | 633 |
| Test methods passed | 633 |
| Failures / errors / skipped | 0 / 0 / 0 |
| Expected failures / unexpected successes | 0 / 0 |
| Current M32 source identities | 34/34 |
| Preserved M32 publication artifact identities | 4/4 |
| Tracked source files recorded and preserved | 995/995 |
| Evidence file SHA-256 checks | 17/17 |

The discovered inventory, executed identifiers, successful identifiers, and individual test-log results agree exactly. All 633 test methods execute from the qualified checkout. Historical publication files remain explicit, revision-bound reference inputs where required by the qualification contracts.

## M32 deterministic RTL replay

The workflow compiles the current M32 RTL and executes each published trace profile twice. Both parsed trace content and emitted protocol records agree between repetitions; parsed traces also match the published M32 bundle.

| Scheduler | Repetitions | Source ticks per repetition | Monitor records per repetition | Active-zero cell observations per repetition |
|---|---|---|---|---|
| 7/1 | 2 | 16 | 192 | 115 |
| 1/7 | 2 | 17 | 204 | 123 |
| One pair of scheduler runs | 2 repetitions per mode | 33 | 396 | 238 |

The replay comparison covers the two published eight-cell trace profiles. The schema, trace bundle, manifest, and qualification artifact remain byte-identical to publication commit `a7efd319b4e3f52d461b19936a4d29d6c94e0d95`, whose recorded source revision is `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941`.

The simulation environment installs the pinned `verilator==5.38.0` distribution in a separate virtual environment and invokes its bundled executable by explicit path. The evidence archive records Python, compiler, package versions, build logs, raw transcripts, and extracted protocol records.

## Changes since v3.4.0-rc.1

- Updated M21, M22, M23, M30, and M32 qualification tests to distinguish current execution from revision-bound publication inputs and identities.
- Updated the M21, M22, and M23 qualification workflows.
- Replaced the workflow 158 split-revision test execution with a single current-checkout 633-test gate, followed by current M32 replay and source-preservation checks.
- Consolidated workflow 158 results into one downloadable evidence artifact with a SHA-256 inventory.

The `rtl` and `verification` trees are unchanged from v3.4.0-rc.1 at `40860748eeddce80375dce568c9a7c1c3cda75fd`.

## Retained RTL coverage evidence

[Workflow 157, run 42797467764](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/42797467764) records 374/374 reached outcomes in the fixed workflow 155 inventory across 27 RTL files. Its source revision is `adcb4c9b0badaf5767458d5142a142574827b0a3`.

The cumulative evidence accounts for 366 outcomes; two byte-identical 64-cell replays cover the remaining eight, including four internal fault-injection cases. The `rtl` and `verification` trees at that revision match the qualified source revision of this candidate.

The earlier post-synthesis and FRP Trace Observatory qualification runs remain documented with their individual scopes in [the v3.4.0-rc.1 release notes](RELEASE_NOTES_v3_4_0_rc_1.md). Current M32 replay preserves the published trace content used by the Observatory.

## Evidence archives

| Qualification | Archive | SHA-256 |
|---|---|---|
| Current 633 tests and M32 replay | `frp-current-633-44069652350-1.zip` | `d79cff2b2fb585cf701e9a96a56a094b0ccae746ebc352154acb83f928cda46c` |
| Fixed RTL branch inventory | `frp-157-coverage-42797467764-1.zip` | `d79d846c5d5aaad5cde281b5fd57fd0be155c9a929eb3bdcc41b4f207e9ca284` |

The current qualification archive includes `SUMMARY.md`, `test-inventory.json`, `current-633.json`, `current-633.log`, `m32-current-replay.json`, `source-manifest.json`, `toolchain.txt`, both build logs, four raw trace logs, four protocol logs, and `SHA256SUMS`.

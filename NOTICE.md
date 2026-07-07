# Notice

**Fractal Resonance Processor (FRP)**

**Ternary Resonant Coherence Processor — Structured Output Prototype**

Copyright 2026 Maksym Marnov

This project is licensed under the Apache License, Version 2.0.

## Current Release

**Version:** `FRP v1.7.0`

**Milestone:** `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

**Main executable reference:** `frp_prototype_v1_7_0.py`

**Primary qualification workflow:** `.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## Repository Scope

The Fractal Resonance Processor (FRP) repository contains the public executable processor reference, structured output, reproducibility, verification, benchmark, comparative architecture, hardware-sensitivity, implementation-mapping, qualification, documentation, governance, and release-evidence layers of the project.

FRP v1.7.0 establishes the current M15 deterministic implementation-mapping and qualification layer.

The current release package includes:

- balanced ternary state and retained-result semantics;
- active neutral transition routing;
- distributed commit behavior;
- deterministic scheduler modes;
- Kuramoto-Sakaguchi resonant phase dynamics;
- hierarchical fractal coupling;
- stateful delay dynamics;
- distributed local thermal dynamics;
- correlated local gamma drift;
- nonlinear coherence compression;
- multiscale phase coherence;
- dynamic stability `C(t) - P(t)`;
- hardware-facing fixed-point representation;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized semantic correlation;
- exact deterministic replay;
- qualification closure.

## Current Qualification State

**Published validation result:** `PASS`

**Validated M15 self-test:** `41/41 PASS`

**M15 artifact layers:** `10`

**Deterministic vector package:** `10/10 files byte-identical`

**Semantic correlation:** `PASS`

**Exact deterministic replay:** `PASS`

**Qualification closure:** `PASS`

## License

See `LICENSE` for the complete Apache License 2.0 terms.

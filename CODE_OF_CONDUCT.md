# Code of Conduct

## 1. Purpose

The Fractal Resonance Processor (FRP) project is a public research, executable semantic reference, implementation-mapping, SystemVerilog RTL execution, target-independent FPGA preparation, verification, benchmark, and documentation repository.

This code of conduct defines the expected standard for participation in issues, pull requests, discussions, and repository collaboration.

## 2. Expected Conduct

Participants are expected to:

- communicate respectfully
- focus on technical content
- provide evidence for technical claims
- attach benchmark and performance statements to their exact metric domain, workload, release, and evidence source
- distinguish historical evidence contours from the current validated architecture
- respect repository scope and documentation boundaries
- avoid personal attacks, harassment, or disruptive behavior
- report security-sensitive issues responsibly

## 3. Unacceptable Conduct

Unacceptable conduct includes:

- harassment, threats, or abusive language
- personal attacks
- repeated off-topic disruption
- intentional misrepresentation of project results or validation evidence
- unsupported technical, implementation, hardware, or performance claims
- publication of private, sensitive, or restricted material
- disclosure of credentials, tokens, keys, secrets, or private access-control material
- attempts to pressure maintainers into accepting unverified claims

## 4. Evidence-Based Discussion

Technical discussion should remain evidence-based.

Claims about FRP behavior should be grounded in:

- repository code
- documented test output
- reproducible benchmark results
- explicit model and workload assumptions
- release-specific metric definitions
- current workflow and qualification evidence

Current project state:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current published validation result:

`PASS`

Inherited M15 self-test result:

`41/41 PASS`

Current M16 RTL qualification:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

## 5. Repository Scope

Discussion and contributions should remain aligned with the public repository scope.

The repository may include:

- public documentation
- executable processor reference code
- structured output and reproducibility instructions
- benchmark interpretation and release-specific evidence
- verification and qualification records
- implementation-mapping artifacts
- hardware-facing interface and correlation documents
- SystemVerilog RTL execution artifacts
- target-independent FPGA preparation artifacts
- mathematical and physical foundation documents
- historical release records

The public repository excludes:

- private access-control material
- credentials, tokens, keys, or secrets
- deployment-sensitive operational details
- unpublished restricted design layers
- private identity or authentication data
- unsafe implementation instructions

## 6. Maintainer Responsibility

Maintainers may:

- edit or close off-topic issues
- reject unsupported claims
- close disruptive discussions
- remove sensitive material
- request additional evidence before accepting changes
- block participants who repeatedly violate this code of conduct

Maintainer decisions should protect project clarity, safety, reproducibility, evidence integrity, and public repository boundaries.

## 7. Reporting

Concerns about conduct or security-sensitive issues should be reported responsibly to the repository maintainer.

Sensitive issues should be reported privately first, with reasonable review time provided before public disclosure.

## 8. Current Status

This code of conduct is aligned with:

- `FRP v1.8.0`
- `M16 — RTL Core Realization and Execution Semantics Package`
- the M15-qualified semantic and implementation-mapping foundation
- `frp_prototype_v1_7_0.py`
- `frp.structured_output.v1.7.0`
- `frp.m3.benchmark_matrix.v1.7.0`
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `docs/limitations.md`
- `docs/mathematical_foundation.md`
- `docs/physical_foundation.md`
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`
- `docs/m16_rtl_core_realization_execution_semantics.md`
- `TEST_REPORT_v1_8_0.md`
- `FRP_VALIDATION_INDEX_v1_8_0.md`
- `RELEASE_NOTES_v1_8_0.md`
- `rtl/m16/CLOSURE.md`
- `fpga/m16/CLOSURE.md`
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`
- `.github/workflows/frp-m16-rtl-artifact-boundary.yml`
- `.github/workflows/frp-m16-fpga-preparation.yml`

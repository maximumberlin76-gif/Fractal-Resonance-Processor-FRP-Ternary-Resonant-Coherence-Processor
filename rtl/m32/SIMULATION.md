# FRP M32 Simulation and Qualification Procedure

## Boundary identity

| Field | Value |
|---|---|
| Project | `Fractal Resonance Processor (FRP)` |
| Milestone | `M32` |
| RTL source boundary commit | `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| Integrated top-level module | `frp_m32_core` |
| Qualified integrated configuration | `8` cells, `2` request lanes |
| Full integrated-core synthesis profile | `8` cells, `2` request lanes |
| FPGA integration top | `frp_m32_fpga_top` |
| FPGA qualification profile | `8` cells, `2` request lanes |
| Canonical inputs per FPGA qualification | `19 / 19 exact` |
| Generated post-synthesis DUT | `frp_m32_fpga_netlist` |
| Registered-boundary synthesis profiles | `8`, `16`, and `32` cells |
| Scheduler trace modes | `7/1` and `1/7` |
| Canonical ternary notation | `-1/0/1` |

This document reproduces the commands encoded in the M32 registered-target,
full integrated-core synthesis, and deterministic trace-export workflows.
It also records the execution procedure and acceptance checks for the FPGA
integration and post-synthesis workflows. Shell commands are executed from
the repository root unless a different working directory is stated.

## Qualification boundaries

| Boundary | Tool and operation |
|---|---|
| Exact source identities | byte count and SHA-256 comparison |
| M32 RTL and testbenches | Verilator lint |
| Registered target boundary | Yosys synthesis for `8`, `16`, and `32` cells |
| Full integrated core | Yosys `read_slang` synthesis for `8` cells and `2` request lanes |
| Full integrated core | flattened netlist, complete port contract, and zero-process checks |
| Phase-interference sine ROM | retained-memory geometry and bit-exact initialization check |
| Full integrated synthesis | two byte-identical JSON, Verilog, and statistics replays |
| FPGA integration | complete wrapper simulation, reset-release control, operation gating, and full synthesis |
| FPGA post-synthesis export | generated simulation netlist with preserved ports, memory parameters, and initialization |
| FPGA post-synthesis simulation | all `59` forwarded core outputs compared against a separate M32 RTL reference across `1019` samples per replay |
| FPGA replay | two complete simulations per workflow, with identical ordered semantic terminal records |
| FPGA evidence | source, workflow, execution, support-file, and output identities retained in qualification records |
| Registered target boundary | bounded Yosys SAT proofs at depth `4` |
| M32 testbenches | Verilator binary build and deterministic replay |
| Scheduler traces | record cardinality, cadence, route-leg, and invariant checks |
| Trace exporter | `49` independent Python tests |
| Canonical outputs | deterministic generation, schema validation, mutation rejection, exact identity, and repository comparison |

The registered-boundary synthesis qualifies
`frp_m32_registered_target_boundary` at `8`, `16`, and `32` cells. The full
integrated synthesis separately qualifies `frp_m32_core` at the canonical M32
configuration of `8` cells and `2` request lanes. The integrated flow uses a
memory-preserving coarse Yosys synthesis so that the `4096 x 32` sine lookup
table remains initialized from the canonical M31 memory file.

## Toolchain

The GitHub Actions jobs use:

| Component | Workflow setting |
|---|---|
| Runner | `ubuntu-24.04` |
| Python | `3.12` |
| Verilator | Ubuntu runner package, version recorded in each run artifact |
| C++ compiler | Ubuntu `g++`, C++20 mode |
| Native build utility | Ubuntu `make`, version recorded by the FPGA workflows |
| Yosys | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog synthesis frontend | Yosys `read_slang`, IEEE `1800-2017` |
| JSON Schema validator | `jsonschema==4.25.1` |
| Locale | `C.UTF-8` |
| Time zone | `UTC` |
| Python hash seed | `0` for the export and FPGA workflows |

Install the execution dependencies:

    sudo apt-get update
    sudo apt-get install --yes --no-install-recommends g++ make verilator
    python -m pip install \
      --disable-pip-version-check \
      yowasp-yosys==0.68.0.0.post1208 \
      jsonschema==4.25.1

Record the active toolchain:

    verilator --version
    g++ --version | head -n 1
    make --version
    python --version
    yowasp-yosys -V
    python -c 'from importlib.metadata import version; print(version("jsonschema"))'

Initialize deterministic shell state and an isolated work directory:

    set -euo pipefail
    export LC_ALL=C.UTF-8
    export TZ=UTC
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONHASHSEED=0
    export M32_WORK_DIR="$(mktemp -d)"

## Source-identity preflight

The canonical exporter validates all `29` M31/M32 source identities, including
the registered-target workflow identity:

    python - <<'PY'
    from pathlib import Path

    import frp_m32_deterministic_rtl_trace_export as m32

    records = m32.validate_source_identities(Path(".").resolve())
    if len(records) != 29:
        raise SystemExit("unexpected M32 source identity count")
    print("FRP M32 source identities: PASS count=29")
    PY

The complete identity table is recorded in
[`ARTIFACTS.md`](ARTIFACTS.md).

The full integrated-core workflow independently verifies the exact byte count
and SHA-256 identity of the `17` source files required by `frp_m32_core`. It
also verifies that the top includes the execution core, phase-interference
engine, registered-target request path, thermal proxy, and stability monitor,
and that the canonical sine memory contains exactly `4096` words.

Each FPGA workflow independently verifies `19` inputs: the same `17`
full-core inputs, `fpga/m32/frp_m32_fpga_top.sv`, and its selected
testbench. The two FPGA manifests share `18` exact non-testbench inputs.
Integration qualification selects `frp_m32_fpga_tb.sv`; post-synthesis
qualification selects `frp_m32_fpga_post_synthesis_tb.sv`.

Both FPGA workflows verify complete include closure from the FPGA top and
their selected testbench, record their own workflow identity separately,
and recheck input byte lengths and SHA-256 values before finalization.

## Verilator lint

Use the same lint function as the registered-target workflow:

    lint_top() {
      local top_module="$1"
      local source_path="$2"

      verilator \
        --lint-only \
        --sv \
        --timing \
        --assert \
        -Wall \
        -Wno-fatal \
        --top-module "$top_module" \
        -Irtl/m31 \
        -Irtl/m32 \
        "$source_path"
    }

    lint_top \
      frp_m32_registered_target_boundary \
      rtl/m32/frp_m32_registered_target_boundary.sv
    lint_top \
      frp_m32_registered_target_boundary_tb \
      rtl/m32/frp_m32_registered_target_boundary_tb.sv
    lint_top \
      frp_m32_registered_target_request_path \
      rtl/m32/frp_m32_registered_target_request_path.sv
    lint_top \
      frp_m32_registered_target_request_path_tb \
      rtl/m32/frp_m32_registered_target_request_path_tb.sv
    lint_top \
      frp_m32_core \
      rtl/m32/frp_m32_core.sv
    lint_top \
      frp_m32_core_tb \
      rtl/m32/frp_m32_core_tb.sv
    lint_top \
      frp_m32_mode_7_1_tb \
      rtl/m32/frp_m32_mode_7_1_tb.sv
    lint_top \
      frp_m32_mode_1_7_tb \
      rtl/m32/frp_m32_mode_1_7_tb.sv
    lint_top \
      frp_m32_trace_monitor \
      rtl/m32/frp_m32_trace_monitor.sv
    lint_top \
      frp_m32_mode_7_1_trace_tb \
      rtl/m32/frp_m32_mode_7_1_trace_tb.sv
    lint_top \
      frp_m32_mode_1_7_trace_tb \
      rtl/m32/frp_m32_mode_1_7_trace_tb.sv

## Registered-boundary synthesis

Run two synthesis replays for each qualified cell profile and compare the
generated JSON netlists:

    synthesize_profile() {
      local cells="$1"
      local replay
      local netlist_path
      local log_path
      local yosys_script

      for replay in 1 2; do
        netlist_path="${M32_WORK_DIR}/boundary-synth-${cells}-run-${replay}.json"
        log_path="${M32_WORK_DIR}/boundary-synth-${cells}-run-${replay}.log"
        yosys_script="read_verilog -sv -I rtl/m31 rtl/m32/frp_m32_registered_target_boundary.sv; chparam -set CELLS ${cells} frp_m32_registered_target_boundary; synth -noabc -top frp_m32_registered_target_boundary; check; stat; write_json ${netlist_path}"

        yowasp-yosys -p "$yosys_script" 2>&1 | tee "$log_path"
        test -s "$netlist_path"
        test "$(grep -Fc 'Found and reported 0 problems.' "$log_path")" -ge 3
        test "$(grep -Fc 'End of script.' "$log_path")" -eq 1
      done

      cmp \
        "${M32_WORK_DIR}/boundary-synth-${cells}-run-1.json" \
        "${M32_WORK_DIR}/boundary-synth-${cells}-run-2.json"
      sha256sum \
        "${M32_WORK_DIR}/boundary-synth-${cells}-run-1.json"
    }

    synthesize_profile 8
    synthesize_profile 16
    synthesize_profile 32

Each profile requires a non-empty netlist, zero reported Yosys problems, a
completed script, and byte-identical replay netlists.

## Full integrated-core synthesis

The full synthesis boundary is the complete `frp_m32_core` hierarchy at the
canonical M32 profile:

| Property | Required value |
|---|---:|
| Top module | `frp_m32_core` |
| Cell count parameter | `8` |
| Request-lane parameter | `2` |
| Top-level ports | `74` |
| Top-level port bits | `3135` |
| Input ports | `15` |
| Output ports | `59` |
| Flattened modules | `1` |
| Remaining RTL processes | `0` |
| Sine ROM | `4096 x 32` |
| Sine ROM read ports | `72` |
| Sine ROM write ports | `0` |

The canonical phase-interference source contains four post-load simulation
checks implemented with `$fatal`. The synthesis workflow does not modify that
tracked source. It creates a temporary synthesis view, removes exactly that
simulation-only check block, and preserves the `$readmemh` statement and its
canonical memory file.

Prepare the synthesis view:

    export M32_SYNTHESIS_VIEW="${M32_WORK_DIR}/frp-m32-full-core-source"
    export M32_SYNTHESIS_RESULTS="${M32_WORK_DIR}/frp-m32-full-core-synthesis"

    mkdir -p \
      "${M32_SYNTHESIS_VIEW}/rtl/m31" \
      "${M32_SYNTHESIS_VIEW}/rtl/m32" \
      "${M32_SYNTHESIS_RESULTS}"
    cp -a rtl/m31/. "${M32_SYNTHESIS_VIEW}/rtl/m31/"
    cp -a rtl/m32/. "${M32_SYNTHESIS_VIEW}/rtl/m32/"

    SYNTHESIS_VIEW="${M32_SYNTHESIS_VIEW}" python - <<'PY'
    import hashlib
    import os
    from pathlib import Path

    view = Path(os.environ["SYNTHESIS_VIEW"])
    canonical_path = Path("rtl/m31/frp_m31_phase_interference.sv")
    staged_path = view / canonical_path

    canonical = canonical_path.read_bytes()
    staged = staged_path.read_bytes()
    if staged != canonical:
        raise SystemExit("staged phase source differs before normalization")

    old = b"""    $readmemh(SIN_LUT_FILE, sin_lut);\n    if (sin_lut[0] !== 32'sd0)\n      $fatal(1, \"FRP M31 sine LUT zero-point mismatch\");\n    if (sin_lut[1024] !== FRP_M31_Q30_ONE)\n      $fatal(1, \"FRP M31 sine LUT quarter-cycle mismatch\");\n    if (sin_lut[2048] !== 32'sd0)\n      $fatal(1, \"FRP M31 sine LUT half-cycle mismatch\");\n    if (sin_lut[3072] !== -FRP_M31_Q30_ONE)\n      $fatal(1, \"FRP M31 sine LUT three-quarter-cycle mismatch\");\n"""
    new = b"""    $readmemh(SIN_LUT_FILE, sin_lut);\n"""

    if canonical.count(old) != 1:
        raise SystemExit("expected LUT simulation-check block was not unique")

    normalized = canonical.replace(old, new, 1)
    if len(canonical) != 11245:
        raise SystemExit("unexpected canonical phase-source length")
    if hashlib.sha256(canonical).hexdigest() != (
        "e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0"
    ):
        raise SystemExit("unexpected canonical phase-source digest")
    if len(normalized) != 10853:
        raise SystemExit("unexpected normalized phase-source length")
    if hashlib.sha256(normalized).hexdigest() != (
        "571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8"
    ):
        raise SystemExit("unexpected normalized phase-source digest")
    if normalized.count(b"$readmemh(SIN_LUT_FILE, sin_lut);") != 1:
        raise SystemExit("LUT initialization was not preserved exactly once")

    staged_path.write_bytes(normalized)
    PY

    test "$(sha256sum rtl/m31/frp_m31_phase_interference.sv | cut -d' ' -f1)" = \
      "e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0"
    test "$(sha256sum \
      "${M32_SYNTHESIS_VIEW}/rtl/m31/frp_m31_phase_interference.sv" \
      | cut -d' ' -f1)" = \
      "571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8"
    test "$(sha256sum \
      "${M32_SYNTHESIS_VIEW}/rtl/m31/frp_m31_sin_q30.mem" \
      | cut -d' ' -f1)" = \
      "adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d"

Run two complete synthesis replays with the IEEE `1800-2017` `read_slang`
frontend and the memory-preserving coarse Yosys flow:

    export M32_CELLS=8
    export M32_REQUEST_LANES=2
    export M32_TOP_MODULE=frp_m32_core

    synthesize_full_core() {
      local replay="$1"
      local json_path="${M32_SYNTHESIS_RESULTS}/m32-full-core-run-${replay}.json"
      local verilog_path="${M32_SYNTHESIS_RESULTS}/m32-full-core-run-${replay}.v"
      local stat_path="${M32_SYNTHESIS_RESULTS}/m32-full-core-stat-run-${replay}.json"
      local log_path="${M32_SYNTHESIS_RESULTS}/m32-full-core-run-${replay}.log"
      local yosys_script

      yosys_script="read_slang -j 1 --std 1800-2017 --ignore-assertions -G CELLS=${M32_CELLS} -G REQUEST_LANES=${M32_REQUEST_LANES} --top ${M32_TOP_MODULE} -Irtl/m31 -Irtl/m32 rtl/m32/frp_m32_core.sv; synth -top ${M32_TOP_MODULE} -run begin:fine; check -assert; tee -o ${stat_path} stat -json -top ${M32_TOP_MODULE}; write_json ${json_path}; write_verilog -noattr -noexpr -nodec ${verilog_path}"

      (
        cd "${M32_SYNTHESIS_VIEW}"
        yowasp-yosys -Q -T -q -l "$log_path" -p "$yosys_script"
      )

      test -s "$json_path"
      test -s "$verilog_path"
      test -s "$stat_path"
      test -s "$log_path"
      test "$(grep -Fc \
        'Build succeeded: 0 errors, 0 warnings' "$log_path")" -eq 1
      test "$(grep -Fc \
        'Found and reported 0 problems.' "$log_path")" -ge 1
      test "$(grep -Fc \
        'Executing MEMORY_COLLECT pass' "$log_path")" -eq 1
      if grep -Fq 'ERROR:' "$log_path"; then
        return 1
      fi
    }

    synthesize_full_core 1
    synthesize_full_core 2

    cmp \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-1.json" \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-2.json"
    cmp \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-1.v" \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-2.v"
    cmp \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-stat-run-1.json" \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-stat-run-2.json"

Validate the complete flattened top-level contract and the retained sine ROM:

    RESULTS_DIR="${M32_SYNTHESIS_RESULTS}" python - <<'PY'
    import json
    import os
    import re
    from collections import Counter
    from pathlib import Path

    results = Path(os.environ["RESULTS_DIR"])
    netlist = json.loads(
        (results / "m32-full-core-run-1.json").read_text(encoding="utf-8")
    )
    stat = json.loads(
        (results / "m32-full-core-stat-run-1.json").read_text(encoding="utf-8")
    )
    lut_path = Path("rtl/m31/frp_m31_sin_q30.mem")

    if set(netlist["modules"]) != {"frp_m32_core"}:
        raise SystemExit("netlist is not the single flattened M32 top")
    module = netlist["modules"]["frp_m32_core"]
    if int(module["attributes"].get("top", "0"), 2) != 1:
        raise SystemExit("M32 netlist top attribute is missing")

    expected_port_rows = """
    clk|input|1
    rst_n|input|1
    tick_enable|input|1
    clear_counters|input|1
    scheduler_mode|input|2
    phase_load_valid|input|1
    phase_load|input|256
    frequency_load_q16|input|256
    gamma_effective_word|input|256
    thermal_node_factor_q30|input|256
    auto_target_enable|input|1
    external_request_valid|input|2
    external_request_cell_index|input|6
    external_request_target|input|4
    external_target_bank|input|16
    phase_word_q|output|256
    frequency_current_q16|output|256
    coupling_field_q16|output|256
    phase_projection_q30|output|256
    phase_target_source|output|16
    registered_target_q|output|16
    registered_target_valid_q|output|1
    phase_target_domain_valid|output|1
    registered_target_domain_valid|output|1
    target_capture_accepted|output|1
    target_capture_rejected|output|1
    accepted_target_capture_events_q|output|32
    rejected_target_capture_events_q|output|32
    registered_request_enable|output|1
    phase_request_valid|output|2
    phase_request_cell_index|output|6
    phase_request_target|output|4
    execution_request_valid|output|2
    execution_request_cell_index|output|6
    execution_request_target|output|4
    execution_target_bank|output|16
    state_out|output|16
    pending_route_out|output|16
    scheduler_mode_q|output|2
    scheduler_state_q|output|3
    ticks_recorded_q|output|32
    scheduler_count_free_q|output|32
    scheduler_count_balance_q|output|32
    scheduler_count_commit_q|output|32
    scheduler_count_excite_q|output|32
    scheduler_count_neutralize_q|output|32
    request_accept|output|2
    request_reject|output|2
    accepted_cell_mask|output|8
    neutral_routed_cell_mask|output|8
    accepted_change_mask|output|8
    accepted_changes|output|32
    capacity_remaining|output|32
    capacity_exhausted|output|1
    switch_load_numerator|output|32
    requested_direct_events|output|32
    prevented_direct_events|output|32
    neutral_routed_events|output|32
    actual_direct_events|output|32
    reserved_state_events|output|32
    queue_overflow_events|output|32
    invariant_flags|output|10
    pair_coherence_q30|output|32
    cluster_coherence_q30|output|32
    global_coherence_q30|output|32
    organization_dispersion_q30|output|32
    normalized_cycle_cost_q16|output|32
    temperature_proxy_q16|output|32
    peak_temperature_proxy_q16|output|32
    thermal_sample_count_q|output|32
    coherence_capacity_q16|output|32
    pressure_q16|output|32
    stability_margin_q16|output|32
    stable|output|1
    """
    expected_ports = {}
    for row in expected_port_rows.strip().splitlines():
        name, direction, width = row.split("|")
        expected_ports[name] = (direction, int(width))

    actual_ports = {
        name: (record["direction"], len(record["bits"]))
        for name, record in module["ports"].items()
    }
    if actual_ports != expected_ports:
        raise SystemExit("M32 top-level port contract mismatch")
    if len(actual_ports) != 74:
        raise SystemExit("M32 top-level port-count mismatch")
    if sum(width for _, width in actual_ports.values()) != 3135:
        raise SystemExit("M32 top-level port-bit mismatch")
    if Counter(direction for direction, _ in actual_ports.values()) != {
        "input": 15,
        "output": 59,
    }:
        raise SystemExit("M32 top-level port-direction mismatch")

    cells = module["cells"]
    if any(not record["type"].startswith("$") for record in cells.values()):
        raise SystemExit("unexpected unresolved or black-box cell type")
    if len(cells) < 7000:
        raise SystemExit("integrated M32 logic contour is incomplete")

    rom = cells.get("u_phase_interference.sin_lut")
    if rom is None or rom["type"] != "$mem_v2":
        raise SystemExit("M32 sine ROM was not retained as memory")

    def binary_parameter(name):
        return int(rom["parameters"][name], 2)

    if binary_parameter("WIDTH") != 32:
        raise SystemExit("M32 sine ROM width mismatch")
    if binary_parameter("SIZE") != 4096:
        raise SystemExit("M32 sine ROM depth mismatch")
    if binary_parameter("ABITS") != 12:
        raise SystemExit("M32 sine ROM address-width mismatch")
    if binary_parameter("RD_PORTS") != 72:
        raise SystemExit("M32 sine ROM read-port contour mismatch")
    if binary_parameter("WR_PORTS") != 0:
        raise SystemExit("M32 sine ROM unexpectedly has write ports")

    lut_words = [
        line.strip()
        for line in lut_path.read_text(encoding="ascii").splitlines()
        if line.strip()
    ]
    if len(lut_words) != 4096:
        raise SystemExit("canonical sine LUT depth mismatch")
    if any(re.fullmatch(r"[0-9A-Fa-f]{8}", word) is None for word in lut_words):
        raise SystemExit("canonical sine LUT word format mismatch")

    expected_init = "".join(
        f"{int(word, 16):032b}" for word in reversed(lut_words)
    )
    if rom["parameters"]["INIT"] != expected_init:
        raise SystemExit("synthesized sine ROM differs from canonical LUT")

    stat_module = stat["modules"].get("\\frp_m32_core")
    if stat_module is None:
        raise SystemExit("M32 synthesis statistics are missing")
    if stat_module["num_processes"] != 0:
        raise SystemExit("unsynthesized processes remain in M32 netlist")
    if stat_module["num_ports"] != 74:
        raise SystemExit("M32 synthesis-stat port-count mismatch")
    if stat_module["num_port_bits"] != 3135:
        raise SystemExit("M32 synthesis-stat port-bit mismatch")
    if stat_module["num_cells_by_type"].get("$mem_v2") != 2:
        raise SystemExit("M32 synthesis memory-cell contour mismatch")

    print("FRP M32 full integrated-core synthesis: PASS")
    PY

    sha256sum \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-1.json" \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-run-1.v" \
      "${M32_SYNTHESIS_RESULTS}/m32-full-core-stat-run-1.json"

The GitHub Actions artifact additionally records both replay netlists, both
logs, both statistics files, the exact source-identity manifest, the temporary
synthesis-view patch, the toolchain record, the structured synthesis evidence,
and a SHA-256 artifact manifest.

## FPGA integration and post-synthesis procedure

Execute the corresponding manual workflow on `main` using the procedure
under [Manual GitHub Actions execution](#manual-github-actions-execution).
Each workflow contains its complete source manifest, tool installation,
build commands, replay comparisons, structural checks, and evidence binding.

| Qualification | Workflow | Simulation top |
|---|---|---|
| FPGA integration | [FRP M32 FPGA Integration Qualification](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) | `frp_m32_fpga_tb` |
| FPGA post-synthesis | [FRP M32 FPGA Post-Synthesis Qualification](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) | `frp_m32_fpga_post_synthesis_tb` |

### Execution preflight and temporary directories

Both workflows check out the dispatched `github.sha` with persisted
credentials disabled. Preflight requires `workflow_dispatch`,
`refs/heads/main`, the expected checked-out commit, and a clean working
tree. Canonical source verification then checks all `19` input files and
their include closure.

The initial step writes these job-specific paths to `GITHUB_ENV`:

| Variable | Integration directory | Post-synthesis directory |
|---|---|---|
| `M32_EVIDENCE` | `$RUNNER_TEMP/frp-m32-fpga-evidence` | `$RUNNER_TEMP/frp-m32-post-synthesis-evidence` |
| `M32_SOURCE` | `$RUNNER_TEMP/frp-m32-fpga-source` | `$RUNNER_TEMP/frp-m32-post-synthesis-source` |
| `M32_BUILD` | `$RUNNER_TEMP/frp-m32-fpga-build` | `$RUNNER_TEMP/frp-m32-post-synthesis-build` |

The jobs use Python `3.12`, Verilator, `g++`, `make`, and
`yowasp-yosys==0.68.0.0.post1208`. Resolved tool versions are saved in
`toolchain.log`, installed Python packages in `python-packages.txt`, and
frontend help in `read-slang-help.log`.

### Integration workflow sequence

1. Lint the complete `frp_m32_fpga_top` with the M31, M32, and FPGA include directories.
2. Build `frp_m32_fpga_tb` with `--timing --assert --binary`, C++20, and two build workers.
3. Reject `PINMISSING`, `IMPLICIT`, and `MULTIDRIVEN` diagnostics in the lint and build logs.
4. Execute the compiled testbench twice, with a `120`-second timeout per replay, and compare the complete ordered semantic records.
5. Copy the verified inputs into `M32_SOURCE` and apply the verified four-check phase-source transformation while retaining canonical ROM initialization.
6. Synthesize the complete FPGA top twice at `CELLS=8` and `REQUEST_LANES=2`; compare both JSON netlists, both Verilog netlists, and both statistics records byte for byte.
7. Validate the complete interface, flattened structure, reset-release wiring, statistics, and canonical sine ROM.
8. Recheck repository integrity, write the qualification report and checksum list, and upload the evidence directory.

Each simulation compares all `59` forwarded core outputs against a
separate complete `frp_m32_core` instance across `1019` samples. Readiness
and reference reset release follow independently supplied test scenarios.

### Post-synthesis workflow sequence

1. Record the same pinned synthesis package and copy its `simlib.v` and `techmap.v` into the evidence directory as `yosys-simlib.v` and `yosys-techmap.v`; save their identities in `cell-models.json`.
2. Lint the complete FPGA top and prepare the verified temporary synthesis view.
3. Run two complete FPGA synthesis replays and compare JSON, Verilog, and statistics outputs byte for byte.
4. Validate the flattened interface, reset-release stages, statistics, and canonical ROM; save `structure.json`.
5. Export each synthesis JSON as a simulation netlist, verify the preserved contracts, and compare both exported JSON files and both exported Verilog files byte for byte; save `simulation-export.json`.
6. Build `frp_m32_fpga_post_synthesis_tb` with the generated `simulation-netlist-1.v` DUT and recorded `yosys-simlib.v` cell models.
7. Reject the same three lint and build diagnostics, execute two simulation replays, and compare the ordered semantic terminal records.
8. Recheck source, workflow, checkout, working-tree, and Yosys support-file identities; bind the required evidence files into the final report and upload the evidence directory.

During each simulation export, after reading the original synthesis JSON,
the workflow executes this Yosys transformation:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_fpga_top frp_m32_fpga_netlist

The standard `$shiftx` map produces explicit selection logic for signed
indices. The original synthesis JSON files retain their byte identities.
The simulation build uses `-DSIMLIB_NOCONNECT`, `--timing --assert --binary`,
C++20, and two build workers.

The DUT is the generated `frp_m32_fpga_netlist`; the reference is a separate
`frp_m32_core` RTL instance. Each replay checks all `59` forwarded outputs
across `1019` samples and validates `core_ready` independently. The
reference reads the canonical sine ROM file; the synthesized DUT uses
the initialization embedded in its netlist.

### Required FPGA structural and export checks

| Check | Required result |
|---|---|
| Synthesis flow | `synth -top frp_m32_fpga_top -run begin:fine`, followed by `check -assert` |
| Flattened synthesis top | one module named `frp_m32_fpga_top` |
| Complete interface | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| Integrated logic size check | at least `7000` synthesized cells |
| Remaining processes, latch cells, and unresolved instances | `0` |
| Retained memory cells | two `$mem_v2` cells |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Reset-release connectivity | constant `1` into stage one, stage one into stage two, stage two driving readiness and core reset consumers |
| Sine ROM | `4096 x 32`, `12` address bits, `72` read ports, `0` write ports |
| ROM initialization | exact match to all `4096` canonical words |
| Statistics | cell count and cell-type inventory agree with the JSON netlist |
| Exported simulation top | one module named `frp_m32_fpga_netlist` |
| Exported port contract | names, directions, widths, and signedness preserved |
| Exported memory contract | all `$mem_v2` parameters and initialization preserved |
| Exported `$shiftx` and `$connect` cells | `0` |
| Exported observation wires | five reset-qualified control names and widths preserved |

The five observed wires are `u_m32_core.tick_enable`,
`u_m32_core.clear_counters`, `u_m32_core.phase_load_valid`,
`u_m32_core.auto_target_enable`, and
`u_m32_core.external_request_valid`. They are observed only; reference
reset expectations come from the test scenario.

### Required FPGA simulation records

Every replay begins its semantic record sequence with these six lines:

    PASS: startup pulses discarded; phase load without tick
    PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause
    PASS: reset reassertion restarts both release stages
    PASS: free, 97 ticks, pause, isolated and concurrent clear
    PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear
    PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear

The integration testbench then requires:

    PASS: 59 outputs match standalone M32 across 1019 samples
    FRP M32 FPGA integration testbench PASS

The post-synthesis testbench then requires:

    PASS: 59 synthesized outputs match standalone M32 across 1019 samples
    FRP M32 FPGA post-synthesis testbench PASS

Each workflow compares its two eight-record sequences byte for byte.
Integration semantic records are saved as `simulation-run-1.txt` and
`simulation-run-2.txt`; post-synthesis semantic records are saved as
`post-synthesis-run-1.txt` and `post-synthesis-run-2.txt`. Complete
simulator output is retained separately in the corresponding `.log` files.

The ternary kernel remains `-1/0/1`. Both testbenches retain active zero
and pending destination polarity through three paused cycles of each
opposite-polarity route, then complete the second leg without a new
request. Each FPGA scheduler scenario records `97` ticks and `97`
accepted target captures, including its initial reset `FREE` tick.
The remaining `96` ticks cover twelve complete periods for `7/1` and
`1/7`.

### Qualification reports and downloaded evidence

| Workflow | Required report schema | Complete evidence files |
|---|---|---:|
| FPGA integration | `frp.m32.fpga-integration-qualification.v1` | `24` |
| FPGA post-synthesis | `frp.m32.fpga-post-synthesis-qualification.v1` | `37` |

Both reports use `qualification.json` and bind the result to
`source_commit`, `run_id`, and `run_attempt`. The accepted report result
is `PASS`. Required final workflow terminal records are:

    FRP M32 FPGA integration qualification: PASS
    FRP M32 FPGA post-synthesis qualification: PASS

The post-synthesis report requires `35` nonempty evidence files and
records their byte lengths and SHA-256 values. `artifacts.sha256` covers
the other `36` files, including `qualification.json`, for a complete
directory of `37` files. The complete inventories are recorded in
[ARTIFACTS.md](ARTIFACTS.md#uploaded-fpga-qualification-artifact) and
[the post-synthesis evidence inventory](ARTIFACTS.md#post-synthesis-evidence-inventory).

After a successful manual run, open its summary and download its evidence
artifact. Check that the report uses the expected schema, records `PASS`,
and identifies that run, attempt, and source commit. From the extracted
artifact directory, verify the recorded file checksums with:

    sha256sum -c artifacts.sha256

Both workflows retain artifacts for `30` days and execute upload and
summary steps with `always()`. A diagnostic archive can therefore be
present after a failed execution; qualification requires the successful
job result and its completed `PASS` report.

## Bounded formal qualification

The formal source contains two top modules:

| Top module | Assertions | Depth | Replay count |
|---|---:|---:|---:|
| `frp_m32_registered_target_boundary_safety_formal` | `10` | `4` | `2` |
| `frp_m32_registered_target_boundary_sequence_formal` | `4` | `4` | `2` |

Run the same bounded proof command used by the workflow:

    prove_top() {
      local top_module="$1"
      local assertion_count="$2"
      local record_prefix="$3"
      local expected_imports
      local replay
      local log_path
      local record_path
      local yosys_script

      expected_imports="$((assertion_count * 4))"
      yosys_script="read_verilog -sv -formal -I rtl/m31 rtl/m32/frp_m32_registered_target_boundary.sv formal/m32/frp_m32_registered_target_boundary_formal.sv; prep -top ${top_module}; flatten; chformal -lower; async2sync; opt_clean; check; sat -prove-asserts -set-def-formal -set-init-zero -seq 4 -timeout 300 -verify"

      for replay in 1 2; do
        log_path="${M32_WORK_DIR}/${record_prefix}-run-${replay}.log"
        record_path="${M32_WORK_DIR}/${record_prefix}-record-run-${replay}.txt"

        yowasp-yosys -p "$yosys_script" 2>&1 | tee "$log_path"
        test "$(grep -Fc 'SAT proof finished - no model found: SUCCESS!' "$log_path")" -eq 1
        test "$(grep -Fc 'Import proof for assert:' "$log_path")" -eq "$expected_imports"

        {
          printf 'top=%s\n' "$top_module"
          printf 'depth=%s\n' "4"
          printf 'assertions=%s\n' "$assertion_count"
          grep -F 'Import proof for assert:' "$log_path"
          grep -F 'Solving problem with' "$log_path"
          grep -F 'SAT proof finished - no model found: SUCCESS!' "$log_path"
        } > "$record_path"
      done

      cmp \
        "${M32_WORK_DIR}/${record_prefix}-record-run-1.txt" \
        "${M32_WORK_DIR}/${record_prefix}-record-run-2.txt"
      sha256sum \
        "${M32_WORK_DIR}/${record_prefix}-record-run-1.txt"
    }

    prove_top \
      frp_m32_registered_target_boundary_safety_formal \
      10 \
      m32-formal-safety
    prove_top \
      frp_m32_registered_target_boundary_sequence_formal \
      4 \
      m32-formal-sequence

## Deterministic simulation replays

Build each testbench once and execute it twice:

    build_and_replay() {
      local top_module="$1"
      local source_path="$2"
      local pass_record="$3"
      local record_prefix="$4"
      local build_dir="${M32_WORK_DIR}/build-${record_prefix}"
      local executable

      verilator \
        --binary \
        --sv \
        --timing \
        --assert \
        -Wall \
        -Wno-fatal \
        -CFLAGS "-std=c++20" \
        --top-module "$top_module" \
        --Mdir "$build_dir" \
        -Irtl/m31 \
        -Irtl/m32 \
        "$source_path"

      executable="${build_dir}/V${top_module}"
      test -x "$executable"

      "$executable" 2>&1 \
        | tee "${M32_WORK_DIR}/${record_prefix}-run-1.log"
      "$executable" 2>&1 \
        | tee "${M32_WORK_DIR}/${record_prefix}-run-2.log"

      cmp \
        "${M32_WORK_DIR}/${record_prefix}-run-1.log" \
            "${M32_WORK_DIR}/${record_prefix}-run-2.log"
      test "$(grep -Fxc \
        "$pass_record" \
        "${M32_WORK_DIR}/${record_prefix}-run-1.log")" -eq 1
    }

    build_and_replay \
      frp_m32_registered_target_boundary_tb \
      rtl/m32/frp_m32_registered_target_boundary_tb.sv \
      "FRP_M32_REGISTERED_TARGET_BOUNDARY_TB: PASS" \
      m32-boundary

    build_and_replay \
      frp_m32_registered_target_request_path_tb \
      rtl/m32/frp_m32_registered_target_request_path_tb.sv \
      "FRP_M32_REGISTERED_TARGET_REQUEST_PATH_TB: PASS" \
      m32-request-path

    build_and_replay \
      frp_m32_core_tb \
      rtl/m32/frp_m32_core_tb.sv \
      "FRP_M32_INTEGRATED_REGISTERED_TARGET_CORE_TB: PASS" \
      m32-core

    build_and_replay \
      frp_m32_mode_7_1_tb \
      rtl/m32/frp_m32_mode_7_1_tb.sv \
      "FRP_M32_REGISTERED_TARGET_MODE_7_1_TB: PASS" \
      m32-mode-7-1

    build_and_replay \
      frp_m32_mode_1_7_tb \
      rtl/m32/frp_m32_mode_1_7_tb.sv \
      "FRP_M32_REGISTERED_TARGET_MODE_1_7_TB: PASS" \
      m32-mode-1-7

    build_and_replay \
      frp_m32_mode_7_1_trace_tb \
      rtl/m32/frp_m32_mode_7_1_trace_tb.sv \
      "FRP_M32_MODE_7_1_TRACE_TB: PASS samples=16" \
      m32-mode-7-1-full-trace

    build_and_replay \
      frp_m32_mode_1_7_trace_tb \
      rtl/m32/frp_m32_mode_1_7_trace_tb.sv \
      "FRP_M32_MODE_1_7_TRACE_TB: PASS samples=17" \
      m32-mode-1-7-full-trace

Accepted terminal records are:

| Testbench | Required terminal record |
|---|---|
| Registered boundary | `FRP_M32_REGISTERED_TARGET_BOUNDARY_TB: PASS` |
| Registered request path | `FRP_M32_REGISTERED_TARGET_REQUEST_PATH_TB: PASS` |
| Integrated core | `FRP_M32_INTEGRATED_REGISTERED_TARGET_CORE_TB: PASS` |
| Mode `7/1` | `FRP_M32_REGISTERED_TARGET_MODE_7_1_TB: PASS` |
| Mode `1/7` | `FRP_M32_REGISTERED_TARGET_MODE_1_7_TB: PASS` |
| Mode `7/1` full trace | `FRP_M32_MODE_7_1_TRACE_TB: PASS samples=16` |
| Mode `1/7` full trace | `FRP_M32_MODE_1_7_TRACE_TB: PASS samples=17` |

## Scheduler and trace checks

Extract the scheduler summary records:

    grep '^M32_MODE_7_1_TRACE ' \
      "${M32_WORK_DIR}/m32-mode-7-1-run-1.log" \
      > "${M32_WORK_DIR}/m32-mode-7-1-trace.log"
    grep '^M32_MODE_1_7_TRACE ' \
      "${M32_WORK_DIR}/m32-mode-1-7-run-1.log" \
      > "${M32_WORK_DIR}/m32-mode-1-7-trace.log"

    test "$(wc -l < "${M32_WORK_DIR}/m32-mode-7-1-trace.log")" -eq 16
    test "$(grep -Fc ' balance_tick=1 commit_tick=0 ' \
      "${M32_WORK_DIR}/m32-mode-7-1-trace.log")" -eq 14
    test "$(grep -Fc ' balance_tick=0 commit_tick=1 ' \
      "${M32_WORK_DIR}/m32-mode-7-1-trace.log")" -eq 2

    test "$(wc -l < "${M32_WORK_DIR}/m32-mode-1-7-trace.log")" -eq 17
    test "$(grep -Fc ' excite_tick=1 neutralize_tick=0 ' \
      "${M32_WORK_DIR}/m32-mode-1-7-trace.log")" -eq 3
    test "$(grep -Fc ' excite_tick=0 neutralize_tick=1 ' \
      "${M32_WORK_DIR}/m32-mode-1-7-trace.log")" -eq 14

Extract the four structured record classes from each full trace:

    extract_trace_records() {
      local mode="$1"
      local source_log="$2"

      grep '^M32_TRACE_' "$source_log" \
        > "${M32_WORK_DIR}/${mode}-records.log"
      grep '^M32_TRACE_SAMPLE ' "$source_log" \
        > "${M32_WORK_DIR}/${mode}-sample.log"
      grep '^M32_TRACE_BANK ' "$source_log" \
        > "${M32_WORK_DIR}/${mode}-bank.log"
      grep '^M32_TRACE_CELL ' "$source_log" \
        > "${M32_WORK_DIR}/${mode}-cell.log"
      grep '^M32_TRACE_REQUEST ' "$source_log" \
        > "${M32_WORK_DIR}/${mode}-request.log"
    }

    extract_trace_records \
      m32-mode-7-1-full-trace \
      "${M32_WORK_DIR}/m32-mode-7-1-full-trace-run-1.log"
    extract_trace_records \
      m32-mode-1-7-full-trace \
      "${M32_WORK_DIR}/m32-mode-1-7-full-trace-run-1.log"

Required record cardinalities are:

| Mode | Sample | Bank | Cell | Request | Total |
|---|---:|---:|---:|---:|---:|
| `7/1` | `16` | `16` | `128` | `32` | `192` |
| `1/7` | `17` | `17` | `136` | `34` | `204` |

Every sample record must contain `invariant_all_valid=1` and zero values for
`actual_direct_events`, `reserved_state_events`, and
`queue_overflow_events`.

The separately observable route coordinates are:

| Mode | First leg | Second leg |
|---|---|---|
| `7/1` | source tick `9`, cell `0`, retained state `0` | source tick `15`, cell `0`, retained state `-1` |
| `1/7` | source tick `10`, cell `0`, retained state `0` | source tick `16`, cell `0`, retained state `-1` |

## Exporter tests

Run the independent exporter suite:

    python -m unittest \
      tests.test_frp_m32_deterministic_rtl_trace_export \
      -v 2>&1 | tee "${M32_WORK_DIR}/m32-exporter-tests.log"

    grep -Eq '^Ran 49 tests in [0-9.]+s$' \
      "${M32_WORK_DIR}/m32-exporter-tests.log"
    test "$(grep -Fxc 'OK' \
      "${M32_WORK_DIR}/m32-exporter-tests.log")" -eq 1

The suite covers parsing, source and transcript identities, schema structure,
coordinate completeness, packed-record agreement, ternary code/value pairs,
registered-boundary separation, route-leg separation, invariants,
deterministic generation, and mutation rejection.

## Canonical trace generation and verification

Use the two replay logs from each full-trace testbench:

    export M32_OUTPUT_ROOT="${M32_WORK_DIR}/canonical-output"

    export M32_MODE_7_1_PRIMARY="${M32_WORK_DIR}/m32-mode-7-1-full-trace-run-1.log"
    export M32_MODE_7_1_REPLAY="${M32_WORK_DIR}/m32-mode-7-1-full-trace-run-2.log"
    export M32_MODE_1_7_PRIMARY="${M32_WORK_DIR}/m32-mode-1-7-full-trace-run-1.log"
    export M32_MODE_1_7_REPLAY="${M32_WORK_DIR}/m32-mode-1-7-full-trace-run-2.log"

    python frp_m32_deterministic_rtl_trace_export.py \
      --repository-root . \
      --mode-7-1-primary "$M32_MODE_7_1_PRIMARY" \
      --mode-7-1-replay "$M32_MODE_7_1_REPLAY" \
      --mode-1-7-primary "$M32_MODE_1_7_PRIMARY" \
      --mode-1-7-replay "$M32_MODE_1_7_REPLAY" \
      --self-test \
      | tee "${M32_WORK_DIR}/m32-export-self-test.json"

    python frp_m32_deterministic_rtl_trace_export.py \
      --repository-root . \
      --output-root "$M32_OUTPUT_ROOT" \
      --mode-7-1-primary "$M32_MODE_7_1_PRIMARY" \
      --mode-7-1-replay "$M32_MODE_7_1_REPLAY" \
      --mode-1-7-primary "$M32_MODE_1_7_PRIMARY" \
      --mode-1-7-replay "$M32_MODE_1_7_REPLAY" \
      --generate \
      | tee "${M32_WORK_DIR}/m32-export-generation.json"

    python frp_m32_deterministic_rtl_trace_export.py \
      --repository-root . \
      --output-root "$M32_OUTPUT_ROOT" \
      --mode-7-1-primary "$M32_MODE_7_1_PRIMARY" \
      --mode-7-1-replay "$M32_MODE_7_1_REPLAY" \
      --mode-1-7-primary "$M32_MODE_1_7_PRIMARY" \
      --mode-1-7-replay "$M32_MODE_1_7_REPLAY" \
      --verify \
      | tee "${M32_WORK_DIR}/m32-export-verification.json"

The self-test requires two byte-identical generation replays and four rejected
mutations. Verification requires the state `EXACT`.

Compare generated outputs with the tracked publication files:

    cmp \
      "${M32_OUTPUT_ROOT}/schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json" \
      schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json
    cmp \
      "${M32_OUTPUT_ROOT}/artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json" \
      artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json
    cmp \
      "${M32_OUTPUT_ROOT}/artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json" \
      artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json
    cmp \
      "${M32_OUTPUT_ROOT}/artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json" \
      artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json

Required raw file identities are:

| Output | Bytes | SHA-256 |
|---|---:|---|
| Schema | `34066` | `534db8227218184cac5d1cabb461dd63b1b61a99e0269c98535539ad3f7d7da2` |
| Trace bundle | `412195` | `62d8c1e6d205b9262a5c950883d3259275d5049f7a896ae12956a210cb75b7e0` |
| Manifest | `7211` | `da011dbc726d6d1fc0b7dbae12afe1e13d8240df64b9474fd0130c94ba005859` |
| Qualification | `4624` | `26ec2d3eadd73b490eb023572101bb78cf5d11561ead91b78b1a30e690458273` |

## Manual GitHub Actions execution

Run the workflows separately from the GitHub interface:

1. Open the repository's **Actions** tab.
2. Select the workflow by its exact displayed name from the table below.
3. Open **Run workflow**, select branch **main**, and start the run.
4. Open the resulting run, check the job result and qualification summary, and inspect its uploaded evidence.

| Displayed workflow name | Qualification scope |
|---|---|
| `FRP M32 Registered Target Core` | RTL identities, lint, registered-boundary synthesis, bounded proofs, deterministic simulations, and scheduler traces |
| `FRP M32 Full Integrated Core Synthesis` | complete M32 core synthesis, replay identity, port contract, and retained sine ROM |
| `FRP M32 FPGA Integration Qualification` | complete FPGA wrapper simulation, reset and operation gating, full synthesis, and evidence |
| `FRP M32 FPGA Post-Synthesis Qualification` | complete FPGA synthesis, verified simulation export, generated-netlist comparison, and evidence binding |
| `FRP M32 Deterministic RTL Trace Export` | exporter tests, canonical publication generation, verification, and exact repository comparison |

Uploading or committing a workflow file does not start a
`workflow_dispatch` run. The selected workflow must be started manually.

## Evidence records

| Record | Path |
|---|---|
| Boundary specification | [`README.md`](README.md) |
| Artifact identities | [`ARTIFACTS.md`](ARTIFACTS.md) |
| Registered-target workflow | [`../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) |
| Full integrated-core synthesis workflow | [`../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) |
| FPGA integration workflow | [`../../.github/workflows/frp-m32-fpga-integration-qualification.yml`](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) |
| FPGA post-synthesis workflow | [`../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml`](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| FPGA integration transcript | [`../../fpga/m32/SIMULATION_TRANSCRIPT.md`](../../fpga/m32/SIMULATION_TRANSCRIPT.md) |
| FPGA post-synthesis transcript | [`../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md`](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) |
| FPGA integration and post-synthesis closure | [`../../fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) |
| Deterministic export workflow | [`../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) |
| Trace schema | [`../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json`](../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json) |
| Trace bundle | [`../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json`](../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json) |
| Manifest | [`../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json`](../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json) |
| Qualification | [`../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json`](../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json) |

## Author

**Maksym Marnov (Alchimist)**  
Berlin, Germany  
ORCID: `0009-0000-0832-9597`

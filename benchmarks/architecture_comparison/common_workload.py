#!/usr/bin/env python3
"""Deterministic architecture-neutral workload generation for FRP comparisons."""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

WORKLOAD_SCHEMA = "frp.benchmark.semantic_workload.v1"
SUITE_NAME = "FRP Comparative Architecture Benchmark Suite"
GENERATOR_NAME = "sha256_counter_v1"
GENERATOR_DOMAIN = b"frp-architecture-comparison-workload-v1\x00"

NEGATIVE_TARGET = "NEGATIVE_TARGET"
POSITIVE_TARGET = "POSITIVE_TARGET"
SEMANTIC_TARGETS = (NEGATIVE_TARGET, POSITIVE_TARGET)
ISSUE_POLICY_TRANSACTION_SERIAL = "transaction_serial"

DEFAULT_NUM_CELLS = 16
DEFAULT_COMMAND_COUNT = 256
DEFAULT_SEED = 76
DEFAULT_MAX_COMPLETION_CYCLES_PER_COMMAND = 64
DEFAULT_FINAL_COOLDOWN_CYCLES = 32


class WorkloadError(ValueError):
    """Raised when a workload profile or command package is invalid."""


@dataclass(frozen=True)
class WorkloadProfile:
    """Architecture-neutral semantic workload configuration."""

    num_cells: int = DEFAULT_NUM_CELLS
    command_count: int = DEFAULT_COMMAND_COUNT
    seed: int = DEFAULT_SEED
    issue_policy: str = ISSUE_POLICY_TRANSACTION_SERIAL
    max_completion_cycles_per_command: int = (
        DEFAULT_MAX_COMPLETION_CYCLES_PER_COMMAND
    )
    final_cooldown_cycles: int = DEFAULT_FINAL_COOLDOWN_CYCLES

    def validate(self) -> None:
        if isinstance(self.num_cells, bool) or not isinstance(
            self.num_cells, int
        ):
            raise WorkloadError("num_cells must be an integer")
        if self.num_cells <= 0:
            raise WorkloadError("num_cells must be greater than zero")

        if isinstance(self.command_count, bool) or not isinstance(
            self.command_count, int
        ):
            raise WorkloadError("command_count must be an integer")
        if self.command_count <= 0:
            raise WorkloadError("command_count must be greater than zero")

        if isinstance(self.seed, bool) or not isinstance(self.seed, int):
            raise WorkloadError("seed must be an integer")
        if not 0 <= self.seed <= 0xFFFFFFFFFFFFFFFF:
            raise WorkloadError(
                "seed must fit in an unsigned 64-bit integer"
            )

        if self.issue_policy != ISSUE_POLICY_TRANSACTION_SERIAL:
            raise WorkloadError(
                f"issue_policy must be "
                f"{ISSUE_POLICY_TRANSACTION_SERIAL!r}"
            )

        if (
            isinstance(self.max_completion_cycles_per_command, bool)
            or not isinstance(
                self.max_completion_cycles_per_command, int
            )
        ):
            raise WorkloadError(
                "max_completion_cycles_per_command must be an integer"
            )
        if self.max_completion_cycles_per_command <= 0:
            raise WorkloadError(
                "max_completion_cycles_per_command must be greater "
                "than zero"
            )

        if (
            isinstance(self.final_cooldown_cycles, bool)
            or not isinstance(self.final_cooldown_cycles, int)
        ):
            raise WorkloadError(
                "final_cooldown_cycles must be an integer"
            )
        if self.final_cooldown_cycles < 0:
            raise WorkloadError(
                "final_cooldown_cycles must be nonnegative"
            )

    def to_dict(self) -> dict[str, Any]:
        self.validate()
        return {
            "num_cells": self.num_cells,
            "command_count": self.command_count,
            "seed": self.seed,
            "issue_policy": self.issue_policy,
            "max_completion_cycles_per_command": (
                self.max_completion_cycles_per_command
            ),
            "final_cooldown_cycles": self.final_cooldown_cycles,
        }

    @classmethod
    def from_mapping(
        cls,
        value: Mapping[str, Any],
    ) -> "WorkloadProfile":
        allowed = {
            "num_cells",
            "command_count",
            "seed",
            "issue_policy",
            "max_completion_cycles_per_command",
            "final_cooldown_cycles",
        }

        unknown = sorted(set(value) - allowed)

        if unknown:
            raise WorkloadError(
                "unknown workload profile field(s): "
                + ", ".join(unknown)
            )

        profile = cls(
            num_cells=value.get(
                "num_cells",
                DEFAULT_NUM_CELLS,
            ),
            command_count=value.get(
                "command_count",
                DEFAULT_COMMAND_COUNT,
            ),
            seed=value.get(
                "seed",
                DEFAULT_SEED,
            ),
            issue_policy=value.get(
                "issue_policy",
                ISSUE_POLICY_TRANSACTION_SERIAL,
            ),
            max_completion_cycles_per_command=value.get(
                "max_completion_cycles_per_command",
                DEFAULT_MAX_COMPLETION_CYCLES_PER_COMMAND,
            ),
            final_cooldown_cycles=value.get(
                "final_cooldown_cycles",
                DEFAULT_FINAL_COOLDOWN_CYCLES,
            ),
        )

        profile.validate()
        return profile


@dataclass(frozen=True)
class SemanticCommand:
    """One architecture-neutral semantic command."""

    command_index: int
    cell_id: int
    semantic_target: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "command_index": self.command_index,
            "cell_id": self.cell_id,
            "semantic_target": self.semantic_target,
        }


def canonical_json_bytes(value: Any) -> bytes:
    """Serialize JSON deterministically for hashing and byte comparison."""

    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        allow_nan=False,
    ).encode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _command_digest(
    seed: int,
    command_index: int,
) -> bytes:
    material = (
        GENERATOR_DOMAIN
        + seed.to_bytes(
            8,
            byteorder="big",
            signed=False,
        )
        + command_index.to_bytes(
            8,
            byteorder="big",
            signed=False,
        )
    )

    return hashlib.sha256(material).digest()


def generate_commands(
    profile: WorkloadProfile,
) -> tuple[SemanticCommand, ...]:
    """Generate the deterministic architecture-neutral command sequence."""

    profile.validate()

    commands: list[SemanticCommand] = []

    for command_index in range(profile.command_count):
        digest = _command_digest(
            profile.seed,
            command_index,
        )

        cell_id = (
            int.from_bytes(
                digest[0:8],
                byteorder="big",
            )
            % profile.num_cells
        )

        semantic_target = SEMANTIC_TARGETS[
            digest[8] & 0x01
        ]

        commands.append(
            SemanticCommand(
                command_index=command_index,
                cell_id=cell_id,
                semantic_target=semantic_target,
            )
        )

    return tuple(commands)


def _digest_payload(
    profile: WorkloadProfile,
    commands: Sequence[SemanticCommand],
) -> dict[str, Any]:
    return {
        "schema": WORKLOAD_SCHEMA,
        "generator": {
            "name": GENERATOR_NAME,
            "domain_hex": GENERATOR_DOMAIN.hex(),
        },
        "workload_profile": profile.to_dict(),
        "semantic_target_domain": list(SEMANTIC_TARGETS),
        "commands": [
            command.to_dict()
            for command in commands
        ],
    }


def summarize_commands(
    commands: Iterable[SemanticCommand],
    num_cells: int,
) -> dict[str, Any]:
    per_target = {
        target: 0
        for target in SEMANTIC_TARGETS
    }

    per_cell = [
        0
        for _ in range(num_cells)
    ]

    command_count = 0

    for command in commands:
        command_count += 1
        per_target[command.semantic_target] += 1
        per_cell[command.cell_id] += 1

    return {
        "command_count": command_count,
        "target_counts": per_target,
        "cell_command_counts": per_cell,
        "cells_with_commands": sum(
            1
            for count in per_cell
            if count > 0
        ),
    }


def build_workload_package(
    profile: WorkloadProfile,
) -> dict[str, Any]:
    """Build the complete deterministic workload package."""

    commands = generate_commands(profile)

    digest_payload = _digest_payload(
        profile,
        commands,
    )

    workload_sha256 = sha256_hex(
        canonical_json_bytes(
            digest_payload
        )
    )

    package = dict(digest_payload)

    package.update(
        {
            "suite_name": SUITE_NAME,
            "workload_sha256": workload_sha256,
            "summary": summarize_commands(
                commands,
                profile.num_cells,
            ),
        }
    )

    validate_workload_package(package)

    return package


def validate_workload_package(
    package: Mapping[str, Any],
) -> None:
    """Validate package structure and recompute the workload digest."""

    if package.get("schema") != WORKLOAD_SCHEMA:
        raise WorkloadError(
            "invalid workload schema"
        )

    generator = package.get("generator")

    if not isinstance(generator, Mapping):
        raise WorkloadError(
            "generator must be an object"
        )

    if generator.get("name") != GENERATOR_NAME:
        raise WorkloadError(
            "invalid generator name"
        )

    if (
        generator.get("domain_hex")
        != GENERATOR_DOMAIN.hex()
    ):
        raise WorkloadError(
            "invalid generator domain"
        )

    profile_value = package.get(
        "workload_profile"
    )

    if not isinstance(
        profile_value,
        Mapping,
    ):
        raise WorkloadError(
            "workload_profile must be an object"
        )

    profile = WorkloadProfile.from_mapping(
        profile_value
    )

    if (
        package.get("semantic_target_domain")
        != list(SEMANTIC_TARGETS)
    ):
        raise WorkloadError(
            "invalid semantic_target_domain"
        )

    raw_commands = package.get("commands")

    if not isinstance(raw_commands, list):
        raise WorkloadError(
            "commands must be a list"
        )

    if (
        len(raw_commands)
        != profile.command_count
    ):
        raise WorkloadError(
            "command count does not match workload profile"
        )

    commands: list[SemanticCommand] = []

    for expected_index, raw in enumerate(
        raw_commands
    ):
        if not isinstance(raw, Mapping):
            raise WorkloadError(
                "each command must be an object"
            )

        command_index = raw.get(
            "command_index"
        )

        cell_id = raw.get(
            "cell_id"
        )

        semantic_target = raw.get(
            "semantic_target"
        )

        if command_index != expected_index:
            raise WorkloadError(
                "command_index sequence is not contiguous"
            )

        if (
            isinstance(cell_id, bool)
            or not isinstance(cell_id, int)
        ):
            raise WorkloadError(
                "cell_id must be an integer"
            )

        if not 0 <= cell_id < profile.num_cells:
            raise WorkloadError(
                "cell_id is outside the configured cell domain"
            )

        if semantic_target not in SEMANTIC_TARGETS:
            raise WorkloadError(
                "invalid semantic_target"
            )

        commands.append(
            SemanticCommand(
                command_index=command_index,
                cell_id=cell_id,
                semantic_target=semantic_target,
            )
        )

    expected_digest = sha256_hex(
        canonical_json_bytes(
            _digest_payload(
                profile,
                commands,
            )
        )
    )

    if (
        package.get("workload_sha256")
        != expected_digest
    ):
        raise WorkloadError(
            "workload_sha256 mismatch"
        )

    expected_summary = summarize_commands(
        commands,
        profile.num_cells,
    )

    if (
        package.get("summary")
        != expected_summary
    ):
        raise WorkloadError(
            "workload summary mismatch"
        )


def load_profile(
    path: Path,
) -> WorkloadProfile:
    try:
        value = json.loads(
            path.read_text(
                encoding="utf-8"
            )
        )
    except OSError as exc:
        raise WorkloadError(
            f"unable to read profile: {path}"
        ) from exc
    except json.JSONDecodeError as exc:
        raise WorkloadError(
            f"invalid JSON profile: {path}"
        ) from exc

    if not isinstance(value, Mapping):
        raise WorkloadError(
            "workload profile JSON must contain an object"
        )

    return WorkloadProfile.from_mapping(
        value
    )


def write_json(
    path: Path,
    value: Any,
) -> None:
    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    text = json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        indent=2,
        allow_nan=False,
    )

    path.write_text(
        text + "\n",
        encoding="utf-8",
    )


def run_self_test() -> dict[str, Any]:
    default_profile = WorkloadProfile()

    package_a = build_workload_package(
        default_profile
    )

    package_b = build_workload_package(
        default_profile
    )

    alternate_profile = WorkloadProfile(
        seed=DEFAULT_SEED + 1
    )

    alternate_package = build_workload_package(
        alternate_profile
    )

    checks = {
        "default_profile_valid": True,
        "default_command_count": (
            len(package_a["commands"])
            == DEFAULT_COMMAND_COUNT
        ),
        "command_indices_contiguous": all(
            row["command_index"] == index
            for index, row in enumerate(
                package_a["commands"]
            )
        ),
        "cell_ids_in_range": all(
            0
            <= row["cell_id"]
            < DEFAULT_NUM_CELLS
            for row in package_a["commands"]
        ),
        "semantic_targets_valid": all(
            row["semantic_target"]
            in SEMANTIC_TARGETS
            for row in package_a["commands"]
        ),
        "both_semantic_targets_present": (
            package_a["summary"][
                "target_counts"
            ][NEGATIVE_TARGET] > 0
            and
            package_a["summary"][
                "target_counts"
            ][POSITIVE_TARGET] > 0
        ),
        "all_default_cells_exercised": (
            package_a["summary"][
                "cells_with_commands"
            ]
            == DEFAULT_NUM_CELLS
        ),
        "deterministic_digest_repeat": (
            package_a["workload_sha256"]
            == package_b["workload_sha256"]
        ),
        "deterministic_byte_repeat": (
            canonical_json_bytes(package_a)
            == canonical_json_bytes(package_b)
        ),
        "seed_changes_workload": (
            package_a["workload_sha256"]
            != alternate_package[
                "workload_sha256"
            ]
        ),
        "digest_length_64": (
            len(
                package_a[
                    "workload_sha256"
                ]
            )
            == 64
        ),
        "package_validation": True,
        "json_roundtrip": (
            json.loads(
                canonical_json_bytes(
                    package_a
                ).decode("utf-8")
            )
            == package_a
        ),
    }

    validate_workload_package(
        package_a
    )

    status = (
        "PASS"
        if all(checks.values())
        else "FAIL"
    )

    return {
        "schema": (
            "frp.benchmark."
            "semantic_workload."
            "self_test.v1"
        ),
        "status": status,
        "check_count": len(checks),
        "checks": checks,
        "default_workload_sha256": (
            package_a[
                "workload_sha256"
            ]
        ),
        "default_summary": (
            package_a["summary"]
        ),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Generate the deterministic "
            "FRP comparative semantic workload."
        )
    )

    parser.add_argument(
        "--profile",
        type=Path,
        help=(
            "Optional workload profile "
            "JSON path."
        ),
    )

    parser.add_argument(
        "--output",
        choices=("json", "text"),
        default="json",
        help="Output format.",
    )

    parser.add_argument(
        "--write",
        type=Path,
        help=(
            "Optional path for the generated "
            "workload JSON package."
        ),
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run deterministic workload "
            "self-tests."
        ),
    )

    return parser


def main() -> int:
    args = build_parser().parse_args()

    try:
        if args.self_test:
            result = run_self_test()

            if args.output == "json":
                print(
                    json.dumps(
                        result,
                        ensure_ascii=False,
                        sort_keys=True,
                        indent=2,
                        allow_nan=False,
                    )
                )
            else:
                print(
                    "FRP COMPARATIVE "
                    "WORKLOAD SELF TEST"
                )

                print(
                    f"status="
                    f"{result['status']}"
                )

                print(
                    f"checks="
                    f"{result['check_count']}"
                )

                print(
                    "default_workload_sha256="
                    f"{result['default_workload_sha256']}"
                )

            return (
                0
                if result["status"] == "PASS"
                else 1
            )

        profile = (
            load_profile(args.profile)
            if args.profile
            else WorkloadProfile()
        )

        package = build_workload_package(
            profile
        )

        if args.write:
            write_json(
                args.write,
                package,
            )

        if args.output == "json":
            print(
                json.dumps(
                    package,
                    ensure_ascii=False,
                    sort_keys=True,
                    indent=2,
                    allow_nan=False,
                )
            )
        else:
            print(
                "FRP COMPARATIVE "
                "SEMANTIC WORKLOAD"
            )

            print(
                f"schema="
                f"{package['schema']}"
            )

            print(
                f"generator="
                f"{package['generator']['name']}"
            )

            print(
                f"commands="
                f"{package['summary']['command_count']}"
            )

            print(
                f"cells="
                f"{profile.num_cells}"
            )

            print(
                f"seed="
                f"{profile.seed}"
            )

            print(
                f"workload_sha256="
                f"{package['workload_sha256']}"
            )

        return 0

    except WorkloadError as exc:
        raise SystemExit(
            f"workload error: {exc}"
        ) from exc


if __name__ == "__main__":
    raise SystemExit(main())

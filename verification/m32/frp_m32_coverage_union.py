# Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
"""Union Verilator source coverage points from qualified run manifests.

Usage: python verification/m32/frp_m32_coverage_union.py --manifest inputs.json
       --source-root . --output coverage-union

Manifest schema: frp.m32.coverage_inputs.v1.
Header fields: commit (full Git SHA), tool (version identity), sources
(repository-relative path to SHA256), required_runs (unique IDs), runs.
Each run supplies id, cells, domain, configuration, files, commit, tool,
source_digest, coverage, coverage_sha256, log, log_sha256, completion.
Artifact paths are relative to the manifest directory. source_digest is the
SHA256 of sources serialized with sorted keys and separators=(',', ':').
The producer records successful test qualification before listing a run.

Groups retain CELLS and the declared verification domain. Source identities
retain every coverage attribute except hierarchy, generated page and instance
aggregation policy; origins retain those attributes. A point is covered when
one observed counter reaches its threshold. Replays do not add partial hits.
The denominator is the union of observed, instrumented source points.
"""
import argparse
import csv
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote


SCHEMA = 'frp.m32.coverage_inputs.v1'
SHA256 = re.compile(r'[0-9a-f]{64}')
SHA1 = re.compile(r'[0-9a-f]{40}')
FAILURE = re.compile(r'%Error|%Fatal|Assertion failed|Aborting|^FAIL\b', re.M)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=True)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, 'Duplicate JSON key: ' + key)
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(), object_pairs_hook=unique_object)


def contained(root, name):
    require(isinstance(name, str) and name, 'Empty path')
    path = (root / name).resolve()
    require(path.is_relative_to(root), 'Path outside declared root: ' + name)
    require(path.is_file(), 'Missing file: ' + name)
    return path


def verified_file(root, name, expected):
    require(isinstance(expected, str) and SHA256.fullmatch(expected), 'Invalid SHA256: ' + name)
    data = contained(root, name).read_bytes()
    require(sha(data) == expected, 'SHA256 mismatch: ' + name)
    return data


def rtl_source(name):
    return name.startswith(('rtl/m31/', 'rtl/m32/')) and name.endswith('.sv') and not name.endswith('_tb.sv')


def decode(value):
    require(not re.search(r'%(?![0-9A-Fa-f]{2})', value), 'Invalid coverage escape')
    return unquote(value, encoding='utf-8', errors='strict')


def source_points(data, selected, source_root, sources):
    lines = data.decode('utf-8').splitlines()
    require(lines and lines[0] == '# SystemC::Coverage-3', 'Unsupported coverage header')
    points, observed = [], set()
    for number, line in enumerate(lines[1:], 2):
        if not line or line.startswith('#'):
            continue
        require(line.startswith("C '"), f'Unknown coverage record at line {number}')
        payload, hits_text = line[3:].rsplit("' ", 1)
        require(re.fullmatch(r'[0-9]+', hits_text), 'Invalid hit count')
        hits = int(hits_text)
        require(payload.startswith('\x01'), 'Missing coverage field delimiter')
        metadata = {}
        for item in payload[1:].split('\x01'):
            pair = item.split('\x02')
            require(len(pair) == 2, 'Invalid coverage field')
            key, value = map(decode, pair)
            require(key not in metadata, 'Duplicate coverage field: ' + key)
            metadata[key] = value
        require({'f', 'l', 'n', 't', 'h', 'page'} <= metadata.keys(), 'Incomplete coverage metadata')
        path = (source_root / metadata['f']).resolve()
        if not path.is_relative_to(source_root):
            require(not rtl_source(metadata['f']), 'RTL path outside source root')
            continue
        name = path.relative_to(source_root).as_posix()
        if name not in selected or metadata['t'] not in ('line', 'branch'):
            continue
        require(name in sources, 'Unfingerprinted RTL source: ' + name)
        require(re.fullmatch(r'[0-9]+', metadata['l']) and
                re.fullmatch(r'[0-9]+', metadata['n']), 'Invalid source position')
        line_number, column = int(metadata['l']), int(metadata['n'])
        require(1 <= line_number <= len(sources[name]), 'Source line outside file: ' + name)
        for span in filter(None, metadata.get('S', '').split(',')):
            require(re.fullmatch(r'[0-9]+(?:-[0-9]+)?', span), 'Invalid covered-line span')
            endpoints = list(map(int, span.split('-')))
            require(1 <= endpoints[0] <= endpoints[-1] <= len(sources[name]), 'Covered-line span outside file')
        threshold = metadata.get('s', '1')
        require(re.fullmatch(r'[0-9]+', threshold) and int(threshold) > 0, 'Invalid coverage threshold')
        identity = {key: value for key, value in metadata.items() if key not in ('h', 'page', 'P')}
        identity.update(f=name, l=str(line_number), n=str(column), s=str(int(threshold)))
        points.append((identity, hits, metadata))
        observed.add(name)
    require(observed == selected, 'Selected RTL files missing coverage: ' + ', '.join(sorted(selected-observed)))
    return points


def analyze(manifest_path, source_root):
    manifest_path, source_root = manifest_path.resolve(), source_root.resolve()
    manifest = read_json(manifest_path)
    require(manifest['schema'] == SCHEMA, 'Unsupported manifest schema')
    require(isinstance(manifest['commit'], str) and SHA1.fullmatch(manifest['commit']), 'Full Git SHA required')
    require(isinstance(manifest['tool'], str) and manifest['tool'].strip(), 'Missing tool identity')
    fingerprints = manifest['sources']
    require(isinstance(fingerprints, dict) and fingerprints, 'Missing source fingerprints')
    source_digest = sha(canonical(fingerprints).encode())
    sources = {}
    for name, expected in fingerprints.items():
        path = contained(source_root, name)
        require(path.relative_to(source_root).as_posix() == name, 'Source path must be canonical: ' + name)
        data = verified_file(source_root, name, expected)
        if rtl_source(name):
            sources[name] = data.decode('utf-8').splitlines()
    required = manifest['required_runs']
    require(isinstance(required, list) and required and all(isinstance(x, str) and x for x in required),
            'Missing required run IDs')
    require(len(set(required)) == len(required), 'Duplicate required run ID')
    require(isinstance(manifest['runs'], list), 'Invalid run list')
    groups, run_reports, seen = {}, [], set()
    for run in manifest['runs']:
        run_id = run['id']
        require(isinstance(run_id, str) and run_id in required and run_id not in seen, 'Unexpected or duplicate run')
        seen.add(run_id)
        require(run['commit'] == manifest['commit'] and run['tool'] == manifest['tool'] and
                run['source_digest'] == source_digest, 'Run provenance mismatch: ' + run_id)
        require(type(run['cells']) is int and run['cells'] in (8, 16, 32, 64), 'Invalid cell count')
        require(isinstance(run['domain'], str) and re.fullmatch(r'[a-z0-9][a-z0-9_-]*', run['domain']),
                'Invalid verification domain')
        require(isinstance(run['configuration'], dict) and run['configuration'], 'Missing elaboration configuration')
        require(isinstance(run['files'], list) and run['files'] and
                all(isinstance(x, str) for x in run['files']), 'Missing selected RTL files')
        selected = set(run['files'])
        require(len(selected) == len(run['files']) and selected <= sources.keys(), 'Invalid selected RTL files')
        log = verified_file(manifest_path.parent, run['log'], run['log_sha256']).decode('utf-8')
        completion = run['completion']
        require(isinstance(completion, str) and completion.startswith('PASS '), 'Invalid completion marker')
        require(not FAILURE.search(log) and log.splitlines().count(completion) == 1 and
                log.count('Verilog $finish') == 1, 'Incomplete or failed simulation: ' + run_id)
        coverage = verified_file(manifest_path.parent, run['coverage'], run['coverage_sha256'])
        points = source_points(coverage, selected, source_root, sources)
        group_key = (run['cells'], run['domain'])
        bins = groups.setdefault(group_key, {})
        local_keys, local_covered = set(), set()
        for identity, hits, metadata in points:
            key = canonical(identity)
            point = bins.setdefault(key, dict(metadata=identity, origins=[]))
            covered = hits >= int(identity['s'])
            point['origins'].append(dict(run=run_id, hierarchy=metadata['h'], page=metadata['page'],
                                        per_instance=metadata.get('P', '0'), hits=hits, covered=covered))
            local_keys.add(key)
            if covered:
                local_covered.add(key)
        run_reports.append(dict(id=run_id, cells=run['cells'], domain=run['domain'],
            configuration=run['configuration'], files=sorted(selected), records=len(points),
            source_points=len(local_keys), covered_source_points=len(local_covered),
            coverage_sha256=run['coverage_sha256'], log_sha256=run['log_sha256']))
    require(seen == set(required), 'Missing required runs: ' + ', '.join(sorted(set(required)-seen)))
    result = dict(schema='frp.m32.coverage_union.v1', status='PASS', commit=manifest['commit'],
        tool=manifest['tool'], source_digest=source_digest, sources=fingerprints,
        manifest_sha256=sha(manifest_path.read_bytes()),
        unit='Observed instrumented source points; any origin reaching its threshold covers the point',
        runs=sorted(run_reports, key=lambda x: x['id']), groups=[])
    for (cells, domain), bins in sorted(groups.items()):
        points, totals = [], defaultdict(lambda: [0, 0])
        for key, point in sorted(bins.items()):
            metadata = point['metadata']
            point['id'] = sha(key.encode())
            point['origins'].sort(key=canonical)
            point['covered'] = any(origin['covered'] for origin in point['origins'])
            point['source_text'] = sources[metadata['f']][int(metadata['l'])-1].strip()
            totals[(metadata['f'], metadata['t'])][0] += int(point['covered'])
            totals[(metadata['f'], metadata['t'])][1] += 1
            points.append(point)
        summary = [dict(file=f, kind=k, covered=c, total=t, uncovered=t-c,
                        percent=round(100*c/t, 3)) for (f, k), (c, t) in sorted(totals.items())]
        observed = {p['metadata']['f'] for p in points}
        result['groups'].append(dict(cells=cells, domain=domain, summary=summary, points=points,
                                    inventory_rtl_without_points=sorted(sources.keys()-observed)))
    return result


def write_report(result, output):
    output.mkdir(parents=True, exist_ok=False)
    (output / 'coverage-union.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    columns = ['cells', 'domain', 'file', 'line', 'column', 'kind', 'point_id', 'description',
               'observed_runs', 'metadata', 'source_text']
    with (output / 'uncovered.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        for group in result['groups']:
            for point in group['points']:
                if point['covered']:
                    continue
                meta = point['metadata']
                writer.writerow(dict(cells=group['cells'], domain=group['domain'], file=meta['f'],
                    line=meta['l'], column=meta['n'], kind=meta['t'], point_id=point['id'],
                    description=meta.get('o', ''), metadata=canonical(meta),
                    observed_runs=','.join(sorted({x['run'] for x in point['origins']})),
                    source_text=point['source_text']))
    text = [f"Commit: `{result['commit']}`", '', result['unit'], '',
            '| Cells | Domain | RTL file | Kind | Covered | Total | Uncovered |',
            '|---:|---|---|---|---:|---:|---:|']
    for group in result['groups']:
        for row in group['summary']:
            text.append(f"| {group['cells']} | {group['domain']} | {row['file']} | {row['kind']} | "
                        f"{row['covered']} | {row['total']} | {row['uncovered']} |")
    (output / 'summary.md').write_text('\n'.join(text) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--source-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = analyze(args.manifest, args.source_root)
    write_report(result, args.output)
    print(f"PASS COVERAGE_UNION runs={len(result['runs'])} groups={len(result['groups'])}")


if __name__ == '__main__':
    main()

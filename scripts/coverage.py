#!/usr/bin/env python3
"""Check the blueprint against `correspondence.toml`.

Coverage and correspondence are what this repository delivers, so the table and
the document have to stay in step. Four things are checked here, cheaply and
without a build:

1.  *One node per labelled entry, one entry per node, chapter for chapter.*
    A node whose label is not in the table is a claim the table does not make;
    an entry with no node is a result the blueprint does not cover. Both are
    silent failures otherwise, and both are cheap to keep fixed if they are
    never allowed to accumulate.

2.  *Tags and statuses agree.* The node tag vocabulary mirrors the `status`
    values one for one (`AGENTS.md`), so that the rendered graph and the table
    can be read against each other. `mapped` reads as `paper` and `informal` as
    `informal-only`; everything else is spelled the same.

3.  *Every module named by an entry exists* in the pinned submodule.

4.  *Every fingerprint in `lt-source-deviations.toml` still matches a witness*
    in the chapter it names. A register entry excuses a specific piece of the
    paper's text; when that text is re-transcribed the entry has to be
    re-reviewed, and the fingerprint is what makes that visible.

With `--reachable` it also reads `_out/reachable.json`, written by
`scripts/reachable.lean`, and reports two things a module inventory cannot say
on its own: modules of the formalization that no entry names at all, and
entries naming a module from which the root theorem reaches nothing. The second
is how `Graph/LooplessMultiGraph.lean` and `Combinatorics/BodyPinCapacity.lean`
were found in module lists they did not belong in.

    python3 scripts/coverage.py
    python3 scripts/coverage.py --reachable
    python3 scripts/coverage.py --summary

Exits 1 if anything fails.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import tomllib
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHAPTERS = ROOT / "BodyPinBlueprint" / "Chapters"

NODE = re.compile(r'^:::(theorem|definition|lemma_|corollary)\s+"([^"]+)"(.*)$', re.M)
TAGS = re.compile(r'\(tags\s*:=\s*"([^"]*)"\)')
WITNESS = re.compile(r'^```tex "([^"]+)"[^\n]*\n(.*?)^```$', re.M | re.S)

# `status` in the table -> the tag a node must carry. The two vocabularies are
# otherwise identical; see AGENTS.md, "Tags carry blueprint state".
STATUS_TAG = {
    "mapped": "paper",
    "deviation": "deviation",
    "informal": "informal-only",
    "gap": "gap",
    "lean-only": "lean-only",
}
EXTRA_TAGS = {"paper", "unwritten"}   # allowed alongside the status tag


def chapter_nodes() -> dict[str, list[tuple[str, set[str]]]]:
    """label and tags of every graph-visible node, by chapter file stem."""
    found: dict[str, list[tuple[str, set[str]]]] = {}
    for path in sorted(CHAPTERS.glob("*.lean")):
        nodes = []
        for _kind, label, rest in NODE.findall(path.read_text(encoding="utf-8")):
            match = TAGS.search(rest)
            tags = {t.strip() for t in match.group(1).split(",")} if match else set()
            nodes.append((label, tags))
        found[path.stem] = nodes
    return found


def check(entries: list[dict], nodes: dict[str, list[tuple[str, set[str]]]]) -> list[str]:
    errors: list[str] = []

    by_label = {}
    for entry in entries:
        label = entry.get("label")
        if label is None:
            continue                      # deliberate: an entry with no node
        if label in by_label:
            errors.append(f"correspondence.toml: duplicate label {label!r}")
        by_label[label] = entry

    seen: set[str] = set()
    for chapter, chapter_nodes_ in nodes.items():
        for label, tags in chapter_nodes_:
            if label in seen:
                errors.append(f"{chapter}: duplicate node label {label!r}")
            seen.add(label)
            entry = by_label.get(label)
            if entry is None:
                errors.append(
                    f"{chapter}: node {label!r} has no labelled entry in correspondence.toml")
                continue
            if entry["chapter"] != chapter:
                errors.append(
                    f"{chapter}: node {label!r} is filed under chapter "
                    f"{entry['chapter']!r} in correspondence.toml")
            status = entry.get("status")
            want = STATUS_TAG.get(status)
            if want is None:
                errors.append(f"correspondence.toml: {label!r} has unknown status {status!r}")
            elif want not in tags:
                errors.append(
                    f"{chapter}: node {label!r} has status {status!r} but no {want!r} tag "
                    f"(tags: {', '.join(sorted(tags)) or 'none'})")
            unknown = tags - set(STATUS_TAG.values()) - EXTRA_TAGS
            if unknown:
                errors.append(
                    f"{chapter}: node {label!r} has tags outside the vocabulary: "
                    f"{', '.join(sorted(unknown))}")

    for label, entry in by_label.items():
        if label not in seen:
            errors.append(
                f"correspondence.toml: entry {label!r} ({entry['chapter']}) has no node")

    formalization = ROOT / "formalization"
    if (formalization / "RB31EndToEnd.lean").exists():
        for entry in entries:
            for module in entry.get("modules", []):
                if not (formalization / module).exists():
                    errors.append(
                        f"correspondence.toml: {entry.get('label', entry['title'])!r} names "
                        f"a module that does not exist: {module}")
    return errors


def fingerprints() -> list[str]:
    """Register entries whose fingerprint no longer matches any witness."""
    register = ROOT / "lt-source-deviations.toml"
    if not register.exists():
        return []
    sys.path.insert(0, str(ROOT / "tools" / "verso-harness" / "scripts"))
    try:
        from check_lt_source_freshness import witness_fingerprint
    except ImportError:                     # harness submodule not checked out
        return []

    present: set[tuple[str, str]] = set()
    for path in sorted(CHAPTERS.glob("*.lean")):
        rel = str(path.relative_to(ROOT))
        for _label, body in WITNESS.findall(path.read_text(encoding="utf-8")):
            present.add((rel, witness_fingerprint(body)))

    with register.open("rb") as handle:
        witnesses = tomllib.load(handle).get("witness", [])
    errors = []
    for item in witnesses:
        digest = item.get("fingerprint")
        if digest is None:
            continue
        if (item["chapter"], digest) not in present:
            errors.append(
                f"lt-source-deviations.toml: {item['paper']!r} has a fingerprint matching no "
                f"witness in {item['chapter']}; re-review the entry and recompute it")
    return errors


def module_name(path: str) -> str:
    """`RB31EndToEnd/Linear/PinRank.lean` -> `RB31EndToEnd.Linear.PinRank`."""
    return path.removesuffix(".lean").replace("/", ".")


def reachability(entries: list[dict]) -> tuple[list[str], list[str]]:
    """Compare the module inventory against what the root theorem actually uses."""
    data = ROOT / "_out" / "reachable.json"
    if not data.exists():
        return [], ["_out/reachable.json is missing; run: lake env lean scripts/reachable.lean"]

    modules = json.loads(data.read_text())["modules"]
    claimed: dict[str, list[str]] = defaultdict(list)
    for entry in entries:
        for path in entry.get("modules", []):
            claimed[module_name(path)].append(entry.get("label") or entry["title"])

    warnings: list[str] = []
    for name, counts in sorted(modules.items()):
        if name in ("RB31EndToEnd",):
            continue
        if counts["reached"] == 0:
            for label in claimed.get(name, []):
                warnings.append(
                    f"{label}: names {name}, of which the root theorem reaches nothing")
        elif name not in claimed:
            warnings.append(
                f"(no entry): {name} has {counts['reached']} reachable declarations "
                "and is named by no entry")
    return [], warnings


def summary(entries: list[dict], nodes: dict[str, list[tuple[str, set[str]]]]) -> None:
    print(f"{'chapter':<16}{'nodes':>6}{'entries':>9}{'verified':>10}{'unwritten':>11}")
    total = [0, 0, 0, 0]
    for chapter in sorted(nodes):
        mine = [e for e in entries if e.get("chapter") == chapter and "label" in e]
        unwritten = sum(1 for _label, tags in nodes[chapter] if "unwritten" in tags)
        verified = sum(1 for e in mine if e.get("verified"))
        row = (len(nodes[chapter]), len(mine), verified, unwritten)
        total = [a + b for a, b in zip(total, row)]
        print(f"{chapter:<16}{row[0]:>6}{row[1]:>9}{row[2]:>10}{row[3]:>11}")
    print(f"{'total':<16}{total[0]:>6}{total[1]:>9}{total[2]:>10}{total[3]:>11}")
    unlabelled = sum(1 for e in entries if "label" not in e)
    print(f"\n{unlabelled} entr{'y' if unlabelled == 1 else 'ies'} deliberately without a node.")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--reachable", action="store_true",
                    help="also compare module inventories against _out/reachable.json")
    ap.add_argument("--summary", action="store_true", help="print the per-chapter table")
    args = ap.parse_args()

    with (ROOT / "correspondence.toml").open("rb") as handle:
        entries = tomllib.load(handle)["entry"]
    nodes = chapter_nodes()

    errors = check(entries, nodes) + fingerprints()
    warnings: list[str] = []
    if args.reachable:
        more, warnings = reachability(entries)
        errors += more

    if args.summary:
        summary(entries, nodes)
        print()

    for warning in warnings:
        print(f"warning: {warning}")
    for error in errors:
        print(f"error: {error}")

    labelled = sum(1 for e in entries if "label" in e)
    counted = sum(len(v) for v in nodes.values())
    if errors:
        print(f"\n{len(errors)} error(s).")
        return 1
    print(f"\n{counted} nodes and {labelled} labelled entries in one-to-one correspondence"
          f"{f'; {len(warnings)} warning(s)' if warnings else ''}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

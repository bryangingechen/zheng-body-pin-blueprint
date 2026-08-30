#!/usr/bin/env python3
"""Check the blueprint against `correspondence.toml`.

Coverage and correspondence are what this repository delivers, so the table and
the document have to stay in step. Everything here is checked cheaply and
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

5.  *Every `def` and `abbrev` a node names has its body quoted*, in a
    ```BodyPinBlueprint.bodies fence in the same chapter, or a `[[body_optout]]`
    row carrying a reason. The panel renders a signature and cannot render a
    value, so a node that names a definition and shows no body leaves the reader
    with `def RB31E2E.EndToEndBodyPinStatement : Prop` and nothing else. The
    taste version of this rule produced fifteen quoted bodies out of thirty-one
    named definitions with no principle separating the halves, which is why it
    is a check.

6.  *The audit chapter's tables match their sources.* The correspondence table,
    the deviations table and the reverse index in `Correspondence.lean` are
    hand-written copies of `correspondence.toml` and
    `lt-source-deviations.toml`, and `audit_chapter` checks every row against
    its source: entries once each with their own locus and status, register
    loci all present under their chapters with each row's chapter link landing
    on the node whose witness the entry fingerprints, every module of the
    pinned formalization exactly once with exactly the entries naming it and
    its name wrapped in the `srcFile` role, which is what links it to the
    module at the pinned repo and rev, and daggers agreeing with
    `_out/reachable.json` when a walk has left one.

7.  *No declaration of the formalization is named as dead text.* Inline, a Lean
    constant goes in a `name` role, which renders the short name, hovers with
    the signature and docstring, and links to the pinned source; a plain code
    span renders as unhighlighted text that goes nowhere. The two look identical
    in the source and completely different on the page, which is why this is
    checked rather than reviewed. It can only see the formalization's own names:
    a Mathlib constant is not resolvable without a build, so `SimpleGraph` in a
    code span stays a review item.

8.  *A formalization file named in prose is a link to the pinned source.* The
    `srcFile` role (`BodyPinBlueprint/SourceLinks.lean`) builds the link from
    the `[formalization]` pin of `correspondence.toml`, so the repository and
    rev are quoted exactly once. A bare `` `Construction.lean` `` code span
    leaves the reader to find the file themselves, and a hand-written URL into
    the formalization's repository re-quotes the pin the role exists to carry;
    both are errors naming the role to write.

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
CITED = re.compile(r'\(lean\s*:=\s*"([^"]+)"\)')
# A `name` role and its label, so the label is not then read as a bare span.
ROLE = re.compile(r"\{name\s+[\w.'!?]+\}`[^`\n]*`")
# An inline code span. Verso's inline math is `$` followed by a backticked
# span, so the lookbehind is what keeps the mathematics out of this.
CODE_SPAN = re.compile(r"(?<!\$)`([^`\n]+)`")
FENCE = re.compile(r'^```BodyPinBlueprint\.bodies[^\n]*\n(.*?)^```$', re.M | re.S)

# One declaration command in the formalization's own source. The pinned
# submodule writes them plainly -- `def`, `noncomputable def`, `private theorem`,
# `@[simp] theorem` -- and always in column zero, which is what makes reading the
# kind off the text possible at all. `kinds_agree` below checks the result
# against the kernel whenever a build has produced one.
DECLARATION = re.compile(
    r'^(?:@\[[^\]]*\]\s*)?'
    r'(?:(?:private|protected|noncomputable|partial|unsafe|scoped|local)\s+)*'
    r'(def|abbrev|theorem|lemma|structure|inductive|instance|class|opaque|axiom)\s+'
    r"([\w.\u00C0-\uFFFF'!?]+)", re.M)
NAMESPACE = re.compile(r'^namespace\s+([\w.\u00C0-\uFFFF]+)', re.M)
SECTION = re.compile(
    r'^(?:(?:private|noncomputable|unsafe)\s+)*section\b', re.M)
END = re.compile(r'^end\b', re.M)

# What a source kind means for the quoting rule. `value` is a body worth showing;
# a structure's fields and an inductive's constructors are already in the panel,
# and a theorem's value is a proof, which this blueprint reproduces none of.
KIND_CLASS = {
    "def": "value", "abbrev": "value", "instance": "value",
    "theorem": "proof", "lemma": "proof",
    "structure": "structure", "inductive": "structure", "class": "structure",
    "opaque": "other", "axiom": "other",
}
# The same classes as the kernel reports them, for `kinds_agree`.
KERNEL_CLASS = {
    "def": "value", "abbrev": "value",
    "theorem": "proof",
    "inductive": "structure", "constructor": "structure",
    "opaque": "other", "axiom": "other",
}
# Kernel kinds with no source-level command of their own: a projection or a
# constructor is declared by its parent structure or inductive, so the source
# scan rightly returns nothing for one, and `quoted_bodies` already reports a
# warning for it. `kinds_agree` must not read that as a scan defect.
KERNEL_SUBDECLARATION = {"constructor", "projection"}

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


def declaration_kinds() -> dict[str, str]:
    """Every declaration in the pinned formalization, mapped to a kind class.

    Read off the source rather than the kernel, because this script runs in the
    fifteen-second check list and in the fast CI workflow, neither of which has
    a built formalization. `kinds_agree` keeps that honest: whenever a build has
    left `_out/body-modules.json` behind, the two are compared and a
    disagreement is an error here.

    Namespaces are tracked so that a short name becomes the qualified one a node
    would cite. `section` is pushed as well, since it is closed by the same
    bare `end`; only `namespace` frames contribute to the prefix.
    """
    formalization = ROOT / "formalization"
    sources = sorted(formalization.glob("RB31EndToEnd/**/*.lean"))
    root_module = formalization / "RB31EndToEnd.lean"
    if root_module.exists():
        sources.append(root_module)

    kinds: dict[str, str] = {}
    for path in sources:
        stack: list[str | None] = []
        for line in path.read_text(encoding="utf-8").splitlines():
            if line[:1] in (" ", "\t"):
                continue
            match = NAMESPACE.match(line)
            if match:
                stack.append(match.group(1))
                continue
            if SECTION.match(line):
                stack.append(None)
                continue
            if END.match(line):
                if stack:
                    stack.pop()
                continue
            match = DECLARATION.match(line)
            if match:
                prefix = ".".join(n for n in stack if n)
                name = f"{prefix}.{match.group(2)}" if prefix else match.group(2)
                kinds.setdefault(name, KIND_CLASS[match.group(1)])
    return kinds


def kinds_agree(kinds: dict[str, str]) -> list[str]:
    """Check the source scan against the kernel, when a build has left one."""
    path = ROOT / "_out" / "body-modules.json"
    if not path.exists():
        return []
    errors = []
    for item in json.loads(path.read_text())["declarations"]:
        if item["kind"] in KERNEL_SUBDECLARATION:
            continue
        want = KERNEL_CLASS.get(item["kind"])
        got = kinds.get(item["name"])
        if want is None or got == want:
            continue
        errors.append(
            f"scripts/coverage.py: reading {item['name']} off the formalization source gives "
            f"{got!r}, but the kernel says {item['kind']!r}; the scan in declaration_kinds "
            "needs fixing before its quoting check can be believed")
    return errors


def chapter_bodies() -> dict[str, tuple[set[str], set[str]]]:
    """Per chapter, the declarations its nodes name and the ones it quotes."""
    found: dict[str, tuple[set[str], set[str]]] = {}
    for path in sorted(CHAPTERS.glob("*.lean")):
        text = path.read_text(encoding="utf-8")
        cited: set[str] = set()
        for match in CITED.finditer(text):
            cited.update(n.strip() for n in match.group(1).split(",") if n.strip())
        quoted: set[str] = set()
        for match in FENCE.finditer(text):
            quoted.update(
                line.strip() for line in match.group(1).splitlines()
                if line.strip() and not line.lstrip().startswith("--"))
        found[path.stem] = (cited, quoted)
    return found


def quoted_bodies(optouts: list[dict]) -> tuple[list[str], list[str]]:
    """Every `def` and `abbrev` a node names is quoted, or is opted out of."""
    if not (ROOT / "formalization" / "RB31EndToEnd.lean").exists():
        return [], ["formalization/ is not checked out; the quoted-body rule is not checked"]

    kinds = declaration_kinds()
    errors = kinds_agree(kinds)
    warnings: list[str] = []

    excused = {}
    for item in optouts:
        if not item.get("reason"):
            errors.append(
                f"correspondence.toml: body_optout {item.get('name')!r} carries no reason")
        excused[item["name"]] = item

    named: set[str] = set()
    for chapter, (cited, quoted) in sorted(chapter_bodies().items()):
        for name in sorted(cited):
            named.add(name)
            kind = kinds.get(name)
            if kind is None:
                # A structure projection is declared by its parent structure, so
                # the source scan rightly returns nothing for it, and it has no
                # body to quote: `State.terminals` is a field of `State`.
                parent = name.rsplit(".", 1)[0] if "." in name else ""
                if kinds.get(parent) == "structure":
                    continue
                warnings.append(
                    f"{chapter}: {name} is named by a node but is not a declaration of the "
                    "pinned submodule's source; the quoted-body rule is not checked for it")
                continue
            if kind != "value" or name in quoted or name in excused:
                continue
            errors.append(
                f"{chapter}: node names {name}, whose body is not quoted. Add it to a "
                "```BodyPinBlueprint.bodies fence in this chapter, or a [[body_optout]] row "
                "in correspondence.toml saying why not (AGENTS.md, 'Mentioning Lean')")

    for name in sorted(excused):
        if name not in named:
            errors.append(
                f"correspondence.toml: body_optout {name!r} excuses a declaration no node "
                "names; drop the row")
    return errors, warnings


def dead_names() -> list[str]:
    """A formalization declaration written as a code span instead of a role.

    `{name RB31E2E.BodyPinIncidence.bodyClique}`bodyClique`` renders the short
    name, hovers with the signature and docstring, and links to the pinned
    source. Plain `` `bodyClique` `` renders as text and does nothing, and the
    difference is invisible in the source -- which is how the statement chapter
    carried one for two phases.

    Only the chapter's own prose is read, not its leading comment: a comment is
    for whoever edits the file and cannot carry a role. Docstrings quoted from
    the formalization are out of reach too, and their backticked names really do
    render as dead text; that is upstream's to fix and is noted in
    `notes/questions.md`.
    """
    if not (ROOT / "formalization" / "RB31EndToEnd.lean").exists():
        return []

    # Index by every dotted suffix, so a span may name a declaration the way the
    # prose would: `bodyClique` as readily as `BodyPinIncidence.bodyClique`.
    by_suffix: dict[str, set[str]] = defaultdict(set)
    for full in declaration_kinds():
        parts = full.split(".")
        for i in range(len(parts)):
            by_suffix[".".join(parts[i:])].add(full)

    errors = []
    for path in sorted(CHAPTERS.glob("*.lean")):
        text = path.read_text(encoding="utf-8")
        start = text.find("#doc (Manual)")
        if start < 0:
            continue
        prose = ROLE.sub("", text[start:])
        for match in CODE_SPAN.finditer(prose):
            span = match.group(1)
            full = sorted(by_suffix.get(span, ()))
            if not full:
                continue
            line = prose[: match.start()].count("\n") + text[:start].count("\n") + 1
            named = full[0] if len(full) == 1 else " or ".join(full)
            errors.append(
                f"{path.stem}:{line}: `{span}` is a declaration of the formalization written "
                f"as a code span, so it renders as dead text. Write "
                f"{{name {named}}}`{span}`, or reword so the name is not code")
    return errors


# The `srcFile` role and its span, so the span is not then read as a bare one.
SRC_ROLE = re.compile(r"\{(?:BodyPinBlueprint\.)?srcFile[^}]*\}`[^`\n]*`")


def file_links(formalization_pin: dict | None) -> list[str]:
    """A formalization file named in prose goes through the `srcFile` role.

    Prose names a file where the file's boundary is the point -- which module
    proves which half, where a namespace and a file part company -- and a bare
    `` `Construction.lean` `` leaves the reader to find it themselves while the
    audit chapter links every module two sections away. The `srcFile` role
    (`BodyPinBlueprint/SourceLinks.lean`) renders the span linked to the file
    at the pinned repo and rev, reading the pin from `correspondence.toml`, and
    it is an elaboration error on a file that does not exist -- so a code span
    whose basename is a module of the pinned submodule must sit inside that
    role, and a hand-written URL into the formalization's repository, which
    re-quotes the pin the role exists to carry, is an error wherever it points.

    Only the chapter's own prose is read, not its leading comment, for the same
    reason as `dead_names`: a comment is for whoever edits the file and cannot
    carry a link.
    """
    formalization = ROOT / "formalization"
    if formalization_pin is None or not (formalization / "RB31EndToEnd.lean").exists():
        return []
    modules = {
        str(p.relative_to(formalization))
        for p in formalization.glob("RB31EndToEnd/**/*.lean")} | {"RB31EndToEnd.lean"}
    by_basename: dict[str, list[str]] = defaultdict(list)
    for module in sorted(modules):
        by_basename[module.rsplit("/", 1)[-1]].append(module)
    repo_url = f"github.com/{formalization_pin['repo']}"

    errors = []
    for path in sorted(CHAPTERS.glob("*.lean")):
        text = path.read_text(encoding="utf-8")
        start = text.find("#doc (Manual)")
        if start < 0:
            continue
        prose = text[start:]
        offset = text[:start].count("\n")
        for match in re.finditer(re.escape(repo_url), prose):
            line = prose[: match.start()].count("\n") + offset + 1
            errors.append(
                f"{path.stem}:{line}: literal URL into {repo_url}; write the srcFile role, "
                "which links at the pinned rev without quoting it")
        # The role's spans are not bare, and a role never spans lines, so the
        # substitution leaves every line number as it was.
        stripped = SRC_ROLE.sub("", prose)
        for match in CODE_SPAN.finditer(stripped):
            span = match.group(1)
            if not span.endswith(".lean"):
                continue
            found = by_basename.get(span.rsplit("/", 1)[-1], [])
            if not found:
                continue
            line = stripped[: match.start()].count("\n") + offset + 1
            errors.append(
                f"{path.stem}:{line}: `{span}` is a file of the formalization written as "
                f"a bare code span; write {{srcFile}}`{span}`, which links it to the "
                "pinned source")
    return errors


def module_name(path: str) -> str:
    """`RB31EndToEnd/Linear/PinRank.lean` -> `RB31EndToEnd.Linear.PinRank`."""
    return path.removesuffix(".lean").replace("/", ".")


BPREF = re.compile(r'\{bpref "([^"]+)"\}')
# A `{bpref "label"}[display]` link, capturing both halves.
BPREF_LINK = re.compile(r'\{bpref "([^"]+)"\}\[([^\]]*)\]')
# The reverse index writes dotted module names, not file paths: the harness
# math-delimiter check reads `A/B.lean` as quotient notation, and whitelists a
# dotted Lean name.
MODULE_CELL = re.compile(r'`(RB31EndToEnd(?:\.[A-Za-z0-9_]+)*)`(\s*†)?')
# The srcFile role a reverse-index module cell wraps its name in, which is what
# renders the name linked to the module at the pinned repo and rev.
MODULE_ROLE = re.compile(r'\{srcFile\}`RB31EndToEnd(?:\.[A-Za-z0-9_]+)*`')

# How the audit chapter's deviations table names each chapter of the register.
CHAPTER_DISPLAY = {
    "Statement": "Statement", "Necessity": "Necessity", "Sparsity": "Sparsity",
    "Deletion": "Deletion", "Flags": "Flags", "Strata": "Strata",
    "SplitKlein": "Split–Klein", "BodyPin": "Body–pin",
    "Correspondence": "Correspondence",
}


def table_rows(section: str) -> list[list[str]]:
    """The rows of every `:::table` in one section, as lists of cell strings.

    A row starts `* * `, each further cell `  * `, and a cell may wrap onto
    more-indented continuation lines. Header rows are included; callers skip
    them by their first cell.
    """
    rows: list[list[str]] = []
    inside = False
    for line in section.splitlines():
        if line.startswith(":::table"):
            inside = True
            continue
        if line.startswith(":::"):
            inside = False
            continue
        if not inside:
            continue
        if line.startswith("* * "):
            rows.append([line[4:].strip()])
        elif line.startswith("  * ") and rows:
            rows[-1].append(line[4:].strip())
        elif line.startswith("    ") and rows and rows[-1]:
            rows[-1][-1] += " " + line.strip()
    return rows


def witness_label_by_fingerprint() -> dict[tuple[str, str], str]:
    """(chapter path, fingerprint) -> the label of the witness carrying it."""
    sys.path.insert(0, str(ROOT / "tools" / "verso-harness" / "scripts"))
    try:
        from check_lt_source_freshness import witness_fingerprint
    except ImportError:                     # harness submodule not checked out
        return {}
    found: dict[tuple[str, str], str] = {}
    for path in sorted(CHAPTERS.glob("*.lean")):
        rel = str(path.relative_to(ROOT))
        for label, body in WITNESS.findall(path.read_text(encoding="utf-8")):
            found[(rel, witness_fingerprint(body))] = label
    return found


def audit_chapter(entries: list[dict]) -> list[str]:
    """Check the audit chapter's hand-written tables against their sources.

    The correspondence table, the deviations table and the reverse index are
    copies of `correspondence.toml` and `lt-source-deviations.toml`, made
    readable; this is what keeps a copy from drifting. Row for row: a node row
    must name a labelled entry with the entry's own paper locus and status, and
    every labelled entry must appear exactly once; a `none` row must match an
    unlabelled entry; the deviations table must carry every register entry's
    locus under its chapter, with the chapter cell linking the node whose
    witness the entry fingerprints (or, for a fingerprint-free entry, some node
    of that chapter); and the reverse index must list every module of
    the pinned formalization exactly once, with exactly the labelled entries
    that name it, a source link to that module at the pinned repo and rev, a
    dagger exactly on the modules the root theorem reaches
    nothing from (when `_out/reachable.json` exists to say which), and no node
    link on a module no labelled entry names.
    """
    path = CHAPTERS / "Correspondence.lean"
    text = path.read_text(encoding="utf-8")
    text = text[text.find("#doc (Manual)"):]
    sections: dict[str, str] = {}
    title = ""
    for part in re.split(r'^# (.+)$', text, flags=re.M):
        if title:
            sections[title] = part
        title = part.strip() if len(part) < 200 else ""
    errors: list[str] = []
    where = "Correspondence"

    # --- the correspondence table against the entries
    section = sections.get("The correspondence table")
    if section is None:
        return [f"{where}: no section 'The correspondence table'"]
    seen_labels: list[str] = []
    seen_unlabelled: list[tuple[str, str]] = []
    for row in table_rows(section):
        if len(row) != 4 or row[0] == "Paper":
            if row[0] != "Paper":
                errors.append(f"{where}: correspondence row has {len(row)} cells: {row[0]!r}")
            continue
        paper, _result, node, status = row
        labels = BPREF.findall(node)
        if len(labels) > 1:
            errors.append(f"{where}: correspondence row {paper!r} links several nodes")
        elif labels:
            seen_labels.append(labels[0])
            entry = next((e for e in entries if e.get("label") == labels[0]), None)
            if entry is None:
                errors.append(f"{where}: correspondence row names unknown label {labels[0]!r}")
                continue
            if entry.get("paper", "—") != paper:
                errors.append(
                    f"{where}: row for {labels[0]!r} says paper {paper!r}, "
                    f"entry says {entry.get('paper', '—')!r}")
            if entry.get("status") != status:
                errors.append(
                    f"{where}: row for {labels[0]!r} says status {status!r}, "
                    f"entry says {entry.get('status')!r}")
        else:
            seen_unlabelled.append((paper, status))
    want_labels = [e["label"] for e in entries if "label" in e]
    for label in want_labels:
        if seen_labels.count(label) != 1:
            errors.append(
                f"{where}: entry {label!r} appears {seen_labels.count(label)} times "
                "in the correspondence table (want exactly once)")
    for label in seen_labels:
        if label not in want_labels:
            errors.append(f"{where}: correspondence table row {label!r} matches no entry")
    want_unlabelled = sorted(
        (e.get("paper", "—"), e["status"]) for e in entries if "label" not in e)
    if sorted(seen_unlabelled) != want_unlabelled:
        errors.append(
            f"{where}: node-less correspondence rows {sorted(seen_unlabelled)} do not match "
            f"the unlabelled entries {want_unlabelled}")

    # --- the deviations table against the register
    register = ROOT / "lt-source-deviations.toml"
    section = sections.get("Deviations register")
    if section is None:
        errors.append(f"{where}: no section 'Deviations register'")
    elif register.exists():
        with register.open("rb") as handle:
            witnesses = tomllib.load(handle).get("witness", [])
        linked: dict[str, str] = {}
        got: list[tuple[str, str]] = []
        for row in table_rows(section):
            if len(row) != 3 or row[0] == "Paper":
                continue
            match = BPREF_LINK.search(row[1])
            if match is None:
                errors.append(f"{where}: deviations row {row[0]!r} has no chapter link")
                got.append((row[0], row[1]))
            else:
                linked[row[0]] = match.group(1)
                got.append((row[0], match.group(2)))
        want = sorted(
            (w["paper"], CHAPTER_DISPLAY[Path(w["chapter"]).stem]) for w in witnesses)
        if want != sorted(got):
            missing = [w for w in want if w not in got]
            extra = [g for g in got if g not in want]
            errors.append(
                f"{where}: deviations table disagrees with lt-source-deviations.toml"
                + (f"; missing {missing}" if missing else "")
                + (f"; extra {extra}" if extra else ""))
        # The chapter cell links the node whose witness the entry excuses: for
        # a fingerprinted entry that node is determined by the fingerprint, and
        # for the fingerprint-free ones any node of the entry's chapter serves.
        witness_labels = witness_label_by_fingerprint()
        entry_by_label = {e["label"]: e for e in entries if "label" in e}
        for item in witnesses:
            label = linked.get(item["paper"])
            if label is None:
                continue                      # already reported above
            digest = item.get("fingerprint")
            want_label = witness_labels.get((item["chapter"], digest)) if digest else None
            if want_label is not None:
                if label != want_label:
                    errors.append(
                        f"{where}: deviations row {item['paper']!r} links {label!r}, but its "
                        f"fingerprint matches the witness on {want_label!r}")
            else:
                entry = entry_by_label.get(label)
                if entry is None or entry["chapter"] != Path(item["chapter"]).stem:
                    errors.append(
                        f"{where}: deviations row {item['paper']!r} links {label!r}, which is "
                        f"not a node of {Path(item['chapter']).stem}")

    # --- the reverse index against the module tree and the inventories
    section = sections.get("Reverse index")
    formalization = ROOT / "formalization"
    if section is None:
        errors.append(f"{where}: no section 'Reverse index'")
    elif (formalization / "RB31EndToEnd.lean").exists():
        named: dict[str, list[str]] = defaultdict(list)
        unlabelled_modules: set[str] = set()
        for entry in entries:
            for module in entry.get("modules", []):
                if not module.startswith("RB31EndToEnd"):
                    continue
                if "label" in entry:
                    named[module].append(entry["label"])
                else:
                    unlabelled_modules.add(module)
        reachable_path = ROOT / "_out" / "reachable.json"
        reached: dict[str, int] | None = None
        if reachable_path.exists():
            reached = {
                name: counts["reached"]
                for name, counts in json.loads(reachable_path.read_text())["modules"].items()}
        want_modules = {
            str(p.relative_to(formalization))
            for p in formalization.glob("RB31EndToEnd/**/*.lean")} | {"RB31EndToEnd.lean"}
        seen_modules: list[str] = []
        for row in table_rows(section):
            if len(row) != 2 or row[0] == "Module":
                if row[0] != "Module":
                    errors.append(f"{where}: reverse-index row has {len(row)} cells: {row[0]!r}")
                continue
            match = MODULE_CELL.search(row[0])
            if not match:
                errors.append(f"{where}: reverse-index row without a module name: {row[0]!r}")
                continue
            module = match.group(1).replace(".", "/") + ".lean"
            if match.group(1) == "RB31EndToEnd":
                module = "RB31EndToEnd.lean"
            dagger = bool(match.group(2)) or "†" in row[0]
            seen_modules.append(module)
            if module not in want_modules:
                errors.append(f"{where}: reverse index lists {module}, which does not exist")
                continue
            if not MODULE_ROLE.search(row[0]):
                errors.append(
                    f"{where}: reverse-index row for {module} does not use the srcFile "
                    "role, so its name is not linked to the pinned source")
            labels = sorted(BPREF.findall(row[1]))
            if labels != sorted(set(named.get(module, []))):
                errors.append(
                    f"{where}: reverse index links {module} to {labels}, but the entries "
                    f"naming it are {sorted(set(named.get(module, [])))}")
            if not labels and module in unlabelled_modules and "no node" not in row[1]:
                errors.append(
                    f"{where}: {module} is named by an entry without a node; say 'no node'")
            if not labels and module not in unlabelled_modules and "(none)" not in row[1]:
                errors.append(
                    f"{where}: {module} is named by no entry; its row must say '(none)'")
            if reached is not None:
                unreachable = reached.get(module_name(module), 0) == 0
                if dagger != unreachable:
                    errors.append(
                        f"{where}: {module} {'carries' if dagger else 'lacks'} a dagger, but "
                        f"the root theorem reaches "
                        f"{'nothing' if unreachable else 'something'} in it")
        for module in sorted(want_modules):
            if seen_modules.count(module) != 1:
                errors.append(
                    f"{where}: {module} appears {seen_modules.count(module)} times in the "
                    "reverse index (want exactly once)")
    return errors


def reachability(entries: list[dict]) -> tuple[list[str], list[str]]:
    """Compare the module inventory against what the root theorem actually uses.

    An entry may name a module the root theorem reaches nothing from, when the
    chapter's account of that module is the point -- the two builds of the ideal,
    the weight apparatus, the superseded orbit modules. Such an entry lists the
    module in its `unreachable` field, with the reason in its `note`, and the
    acknowledgment is checked in both directions: a listed module that becomes
    reachable is an error (the acknowledgment is stale), and an unlisted one
    still warns.
    """
    data = ROOT / "_out" / "reachable.json"
    if not data.exists():
        return [], ["_out/reachable.json is missing; run: lake env lean scripts/reachable.lean"]

    modules = json.loads(data.read_text())["modules"]
    claimed: dict[str, list[str]] = defaultdict(list)
    acknowledged: dict[str, list[str]] = defaultdict(list)
    errors: list[str] = []
    for entry in entries:
        label = entry.get("label") or entry["title"]
        for path in entry.get("modules", []):
            claimed[module_name(path)].append(label)
        for path in entry.get("unreachable", []):
            if path not in entry.get("modules", []):
                errors.append(
                    f"correspondence.toml: {label!r} acknowledges {path} as unreachable "
                    "but does not name it in `modules`; drop the acknowledgment")
                continue
            acknowledged[module_name(path)].append(label)

    warnings: list[str] = []
    for name, counts in sorted(modules.items()):
        if name in ("RB31EndToEnd",):
            continue
        if counts["reached"] == 0:
            for label in claimed.get(name, []):
                if label in acknowledged.get(name, []):
                    continue
                warnings.append(
                    f"{label}: names {name}, of which the root theorem reaches nothing; "
                    "acknowledge it in the entry's `unreachable` list or drop it")
        else:
            for label in acknowledged.get(name, []):
                errors.append(
                    f"correspondence.toml: {label!r} acknowledges {name} as unreachable, "
                    f"but the root theorem reaches {counts['reached']} of its declarations; "
                    "the acknowledgment is stale -- re-review the entry")
            if name not in claimed:
                warnings.append(
                    f"(no entry): {name} has {counts['reached']} reachable declarations "
                    "and is named by no entry")
    return errors, warnings


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
        table = tomllib.load(handle)
    entries = table["entry"]
    nodes = chapter_nodes()

    body_errors, warnings = quoted_bodies(table.get("body_optout", []))
    errors = (check(entries, nodes) + fingerprints() + body_errors + dead_names()
              + file_links(table.get("formalization"))
              + audit_chapter(entries))
    if args.reachable:
        more, reachable_warnings = reachability(entries)
        errors += more
        warnings += reachable_warnings

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

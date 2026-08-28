# Start here

Read in this order before doing anything:

1. `PLAN.md` — what this blueprint is for, chapter structure, decisions and
   their reasons, phases, and what to do next.
2. `correspondence.toml` — the paper -> Lean mapping. The spine of the project.
3. The rest of this file — repo-level policy.
4. `notes/` — `attribution.md` (provenance and what has been checked against
   primary sources), `upstream.md` (harness/verso findings), `questions.md`
   (open reading questions), `reachability.md` (what the root theorem actually
   uses, and the module-inventory errors that measurement caught).

Conventions are kept next to what they govern, so you can skip what is not
relevant to the task in hand:

| Where | What it covers |
|---|---|
| this file | repo-level policy, the harness, the no-TeX-source situation, build costs |
| `BodyPinBlueprint/AGENTS.md` | writing a chapter: witnesses, nodes, labels, tags, citations, imports, edges, markup |
| `BodyPinBlueprint/STYLE.md` | the register blueprint prose is written in, and `scripts/style-check.py` |
| `source/references/AGENTS.md` | third-party reference PDFs (local only, gitignored) |

`BodyPinBlueprint/Chapters/Statement.lean` is the worked example: copy its shape.

Quick sanity check that the repo is healthy:

```bash
bash ./scripts/check-source.sh      # is the right paper revision present?
bash ./scripts/checks.sh            # everything that does not need a build, ~15 s
bash ./scripts/ci-pages.sh          # ~10 min warm, ~45 min cold; runs checks.sh first
```

`scripts/checks.sh` is the whole no-build check list in one place: harness
layout, node kinds, math delimiters, heading structure, quoted snippets against
the pinned submodule, coverage and correspondence, and the prose register. CI
runs it as its own workflow, ahead of the Pages build.

---

# What this blueprint is for

This repository is an **unofficial** blueprint for someone else's paper and
formalization; read `README.md` for the scope statement before writing prose.

The upstream formalization is **already complete** — no `sorry`, no custom
axioms, axiom closure exactly `propext`, `Classical.choice`, `Quot.sound`. So
this is not a coordination blueprint. Its job is to let a reader check,
statement by statement, that the Lean development proves *the paper's theorem*,
and to make visible where the Lean route departs from the written argument.
Coverage and correspondence are the deliverable; progress percentage is not.

# No TeX source (permanent)

The paper was distributed as a PDF; no LaTeX source exists to obtain. Therefore:

- `lt.default_chapters` stays `[]` and `tex_source_glob` is a placeholder.
- The harness LT (source-fidelity) pipeline — `check_lt_source_pairs`,
  `check_lt_similarity`, `check_lt_source_freshness`, and the `lt_audit.py`
  wrapper around them — does **not** apply. Do not try to make it run. It is
  documented in `tools/verso-harness/references/lt-method.md` if a source ever
  appears.
- `check_source_label_grounding.py` likewise has nothing to ground against: we
  deliberately write no `\label{...}` in a witness.
- Source-independent harness checks **do** apply and should be used:
  `check_harness.py`, `check_blueprint_node_kinds.py`,
  `check_verso_math_delimiters.py`, `check_blueprint_heading_structure.py`.
- `tex` witness blocks are therefore hand-transcribed, and "witness matches the
  paper" is a review item. `scripts/check-witness-prose.py` narrows it: it
  checks that the words of every witness occur in `source/paper.txt`, which
  catches a typo or an invented clause, and it reports the seams where a witness
  joins two separated pieces of the paper. It cannot judge a transcription, and
  every seam it reports should be named in its chapter's leading comment. The
  mechanics are in `BodyPinBlueprint/AGENTS.md`.
- `source/` is gitignored apart from its README: the paper is not ours to
  redistribute. Run `bash ./scripts/check-source.sh` before writing prose; it
  verifies `source/paper.pdf` against the hash in `correspondence.toml` and
  regenerates the text layer. A hash mismatch means the paper revision changed
  and the correspondence entries need re-checking before they are cited.

# The formalization is read-only

`formalization/` is a pinned submodule of someone else's repository, which
carries **no licence**. Never vendor its sources, copy proof snippets into this
repo, or commit changes inside the submodule. The same applies to
`tools/verso-harness`: it is a submodule, so nothing — including an `AGENTS.md`
— can be added inside either of them.

# Coverage and correspondence

`correspondence.toml` and the document are two halves of one claim, so they are
checked against each other rather than kept in step by hand.

- `python3 scripts/coverage.py` enforces one node per labelled entry and one
  entry per node, chapter for chapter; that node tags and table statuses agree;
  that every module named exists; and that every fingerprint in
  `lt-source-deviations.toml` still matches the witness it excuses. It is in
  `checks.sh`, so it runs before every build. Add a node and its entry in the
  same commit.
- `lake env lean scripts/reachable.lean` walks the constant dependencies of the
  root theorem through the kernel environment and writes `_out/reachable.json`
  (about three minutes, almost all olean loading — background it). Then
  `python3 scripts/coverage.py --reachable` reports modules the root theorem
  reaches that no entry names, and entries naming a module it reaches nothing
  from. A `modules` list assembled by reading imports overstates dependency in
  both directions; this is the check that catches it, and it has caught it
  three times so far. Rerun when the submodule pin moves.
  `notes/reachability.md` holds the standing result and what it changed.

# Attribution

- Mathematical credit runs through the bibliography. Cite the paper on every
  `paper`-tagged node, and cite the upstream references at the points the paper
  invokes them. Getting those right matters more than claiming anything here.
- `owner` metadata is triage, not credit; see `BodyPinBlueprint/AGENTS.md`.
- Record provenance facts in `notes/attribution.md` as you find them, including
  what you did *not* check. Its "Checked against primary sources" section is the
  tracked record of which claims rest on a source and which rest on the paper's
  report of one.

# Harness notes

The shared harness is the submodule at `tools/verso-harness`. The LT half of it
does not apply here (see above); what follows is the half that does.

- Keep the root `verso-harness.toml` checked in and treat it as the source of
  truth for package layout and paths.
- Keep `lakefile.lean` aligned with its warning policy, especially
  `harness.strict_external_code`. Generated consumers keep the
  version-appropriate Verso math-lint option enabled, disable the noisy
  `VersoManual` inline-code line-length warning, and default the strict-resolve
  option from that key.
- `harness.docstring_warnings` decides whether standard harness workflows
  surface missing-docstring warnings. Default is hidden, until the repo is ready
  to work through them explicitly.
- Prefer the pattern where `VersoBlueprint` drives the `verso` dependency rather
  than pinning `verso` directly.
- Worth reading before structural work:
  `tools/verso-harness/references/layout.md`,
  `porting.md`, `maintenance.md`. (`lt-method.md` and `retrofit.md` describe
  workflows this repo does not use.)
- Start maintenance with
  `python3 tools/verso-harness/scripts/status_harness.py --project-root .` to
  see helper, upstream and `VersoBlueprint` drift, then
  `check_harness.py --project-root .` to audit the layout.
- Treat the host formalization as the source of truth for what is proved.
- Keep the root build green. If a Lean link would pull in imports that are not
  harness-clean on the current toolchain, leave the node informal and note the
  dependency in prose instead.
- Port coherent chapter blocks rather than scattering small edits across
  unrelated chapters. Run `bash ./scripts/ci-pages.sh` after a batch.
- If using sub-agents, prefer one per chapter or per clearly disjoint file set;
  do not split one chapter across agents unless one side is read-only; merge
  chapter edits before running shared validation.
- If using `lean-beam`, avoid parallel `sync` calls against the same project
  root unless the target repo is known to tolerate it.

# Background the full build; never read a stale one

`scripts/ci-pages.sh` takes about ten minutes and is the only gate that checks
everything. Run it in the background and keep working — the two fast loops above
cover most questions in the meantime, and a second `lake` invocation during a
background build completed cleanly in testing, so the preview can run while the
gate is in flight.

The hazard is not concurrency. It is reading output that no longer matches the
source, and it is easy to miss because stale HTML looks completely normal. This
project has drawn wrong conclusions from it more than once: a chapter edited
while `ci-pages.sh` was running produced a site rendered from the *previous*
elaboration, which was then inspected and reported on as if it were current.

So both builds stamp their output with a hash of every input that can affect a
rendered page — the blueprint sources, the entry points, the lakefile, the
toolchain, and the pinned formalization SHA. Before believing anything about a
page:

```bash
python3 scripts/check-fresh.py      # exits 1 if any output is stale
```

And to look at a page rather than grep it, serve the directory — the preview
panels and the search box fetch JSON, which a browser blocks on `file://`.
`README.md`, "Reading it locally", has the one-line command.

Background anything slow, and then *do not foreground a wait for it*. A loop
that polls a log until the build finishes is just the ten minutes again, wearing
a disguise — it blocks the session, and it hits the tool timeout. Launch the
build, go do something else, and check the log when you next have a reason to.
This is the most frequently broken rule here; it was broken several times while
Phase 1 was being written.

Rules that follow, and they are cheap to keep:

- Never quote, measure, or claim anything about a rendered page without
  `check-fresh.py` reporting `current` for that output.
- A build in flight is not a result. Wait for its exit line *and* the stamp.
- If you edit a source file after launching a build, that build is dead to you.
  Relaunch it; do not read what it produces.

A git worktree would isolate the sources, but it does not address this failure
mode and costs a second `.lake` of several gigabytes plus a cold build. Stamping
is the cheaper fix for the problem that actually occurs.

# Build costs (measured 2026-08-27, M-series mac, cold)

- `lake update` + mathlib cache fetch: ~1 min (8,232 cached files).
- `lake build RB31EndToEnd`: **~37 min**, 8,374 jobs, 126 modules. Slowest
  individual modules 90–110 s (`UniversalDistinctChartContraction`,
  `GroundedTwistSplit`, `WittShearDistinctPrime`); most of the final assembly
  spine 55–75 s each. Cost is spread evenly rather than concentrated, so there
  is no single file worth optimising around.
- `lake exe vbp build` (cold, includes building Verso itself): ~8.5 min.
- `lake env lean scripts/reachable.lean`: ~3 min warm, essentially all of it
  loading the root module's oleans.
- Warm, a chapter's build time is almost entirely olean loading, and is set by
  what it imports: 47 s for a Mathlib-blanket-free formalization module, 101 s
  for `Mathlib`, 169 s for the `RB31EndToEnd` root module. A chapter's own
  content — nodes, witnesses, declaration references, quoted bodies — costs
  under 10 s. See the import-granularity rule in `BodyPinBlueprint/AGENTS.md`,
  which now has a measured payoff and not just an auditability one.
- Only CI pays the full cold cost, so the workflow's dependency cache matters.
- Do not iterate with `lake build` or `ci-pages.sh`. Two fast loops cover almost
  everything, both documented in `BodyPinBlueprint/AGENTS.md`:
  `python3 scripts/preview.py` renders the whole document without the
  formalization in 6–26 s, and the `lean-lsp` MCP server re-checks a chapter's
  elaboration in ~8 s. Between them they miss only what depends on the
  formalization being linked — declaration panels, hovers, highlighted Lean,
  node status — so a full `scripts/ci-pages.sh` remains the last step before
  committing and the only thing CI runs.

# Three-Dimensional Body–Pin Rigidity

An **unofficial** Verso blueprint relating Denzel Zheng's paper *Stress
Degeneracy of Direction Complexes of (2,2)-Sparse Graphs and Three-Dimensional
Body–Pin Rigidity* (August 2026, DOI
[10.13140/RG.2.2.17830.28485](https://doi.org/10.13140/RG.2.2.17830.28485)) to
its [Lean 4
formalization](https://github.com/DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture).

All mathematical results are the author's; errors in this exposition are ours.
Nothing here is endorsed by him.

The formalization is already complete — no `sorry`, no custom axioms, axiom
closure exactly `propext`, `Classical.choice`, `Quot.sound`. So this is not a
coordination blueprint. Its job is to let a reader check, statement by
statement, that the Lean development proves *the paper's theorem*, and to make
visible where the Lean route departs from the written argument. Coverage and
correspondence are the deliverable; progress percentage is not.

## Layout

- `PLAN.md` — structure, decisions and their reasons, phases, what to do next.
- `AGENTS.md` — conventions. Read it before editing anything.
- `correspondence.toml` — the paper → Lean map. The spine of the project.
- `lt-source-deviations.toml` — where a result is mapped but proved by a
  different route.
- `BodyPinBlueprint/` — the blueprint itself; chapters under `Chapters/`.
- `formalization/` — the upstream Lean development, pinned as a submodule.
  **Read-only**: it carries no licence, so never vendor its sources or commit
  inside it.
- `source/` — the paper. Gitignored apart from its README; it is not ours to
  redistribute.
- `tools/verso-harness/` — the shared harness, as a submodule.
- `notes/` — attribution and provenance, upstream findings, open reading
  questions.

## There is no TeX source

The paper was distributed as a PDF and no LaTeX source exists to obtain, so the
harness's source-fidelity pipeline (`check_lt_source_pairs`,
`check_lt_similarity`, `check_lt_source_freshness`) does not apply here:
`lt.default_chapters` is empty and `tex_source_glob` is an inert placeholder.
Source-independent harness checks do apply and are used.

The `tex` witness blocks next to blueprint nodes are therefore hand-transcribed
from `source/paper.txt`, and no script can score them against an upstream file.
"Does this witness match the paper?" is an explicit review item.

## Working on it

Populate `source/` first (see `source/README.md`), then:

```bash
bash ./scripts/check-source.sh   # right paper revision? regenerates paper.txt
python3 tools/verso-harness/scripts/check_harness.py --project-root .
bash ./scripts/ci-pages.sh       # ~5 min warm, ~45 min cold
```

Source-independent per-chapter checks:

```bash
python3 tools/verso-harness/scripts/check_blueprint_node_kinds.py --project-root . BodyPinBlueprint/Chapters/Statement.lean
python3 tools/verso-harness/scripts/check_verso_math_delimiters.py --project-root . BodyPinBlueprint/Chapters/Statement.lean
python3 tools/verso-harness/scripts/check_blueprint_heading_structure.py --project-root . BodyPinBlueprint/Chapters/Statement.lean
```

Local output lands in `_out/site/html-multi/index.html`.

## Pages

- Public site: configure after GitHub Pages is enabled for this repo.
- Workflow: `.github/workflows/blueprint.yml`, via the upstream
  `verso-blueprint` reusable workflow. The dependency cache matters: a cold
  formalization build is about 37 minutes.

## Notes

- Root `lean-toolchain` follows the upstream formalization toolchain, which is
  what pins the release line to `v4.29.0`.
- `lakefile.lean` pins the matching `VersoBlueprint` branch, and requires
  `mathlib` **last** so that Mathlib's own dependency pins win — without that,
  `lake exe cache get` computes wrong hashes and refuses to fetch. See
  `notes/upstream.md` §1.
- `harness.docstring_warnings` in `verso-harness.toml` controls whether
  helper-owned workflows show missing-docstring warnings.

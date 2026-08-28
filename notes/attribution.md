# Attribution and provenance notes

Running log. Filled in incrementally; feeds `BodyPinBlueprint/Bibliography.lean`
and the front matter. See `AGENTS.md` for the rule that `owner` metadata is
triage, not mathematical credit.

## The paper

- Denzel (Dongzhe) Zheng, *Stress Degeneracy of Direction Complexes of
  (2,2)-Sparse Graphs and Three-Dimensional Body–Pin Rigidity*, August 2026.
- Citation DOI: `10.13140/RG.2.2.17830.28485` (ResearchGate).
- No arXiv version as of 2026-08-27. **Open question for the author:** is one
  planned? The whole blueprint hangs on this one citation and a ResearchGate DOI
  is a weaker permanence guarantee.
- Exact version mapped by the correspondence table — record this, because
  result numbering shifts between preprint revisions:
  - file: `zheng-2026-body_pin_partition_collinearity_flag_en_20260816.pdf`
  - size: 649632 bytes
  - SHA-256: `c3cbf64f8bbb719bd886fd940af5474b821d7e598af8e087d48fb345f521ab43`
- No LaTeX source available; distributed as PDF. See `AGENTS.md`, "No TeX
  source".

## The author's informal research note

- *Stress Degeneracy, Collinearity Flags, and Three-Dimensional Body–Pin
  Rigidity*,
  <https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/>,
  20 August 2026. © Dongzhe (Denzel) Zheng, no licence stated. Title and date
  confirmed against the live page, 2026-08-27.
- Six sections tracking the paper's argument in prose: the partition criterion;
  the Euclidean gap left by the cofactor theorem; stress degeneracy as a
  codimension estimate; why vertex deletion needs collinearity flags; from
  stress codimension to the body–pin theorem; what the Lean formalization
  verifies.
- Planned placements: Introduction (reader's on-ramp); the route-comparison
  chapter for paper §4 (its second and third sections are exactly that framing);
  per-chapter further-reading pointers; bibliography as a secondary entry.
- Publishes the paper's three figures as standalone SVG under
  `blog/body-pin-rigidity-collinearity-flags/figures/`. **Not reusable** —
  flattened path data, hardcoded `rgb()` strokes, no text elements, and
  copyrighted. Redraw instead.
- Foregrounds four background references, which is a useful signal about which
  of the paper's 31 to get right first:
  - Jackson, Jordán, Villányi, *Rank Contributions of Vertices in Rigidity
    Matroids of Clique Covered Graphs*, arXiv:2607.26266v1 (2026) — esp.
    Conjecture 7.6 and Theorems 7.7–7.8
  - Király, Tanigawa, *Rigidity of Body-Bar-Hinge Frameworks*, Handbook of
    Geometric Constraint Systems Principles, ch. 20 — Conjecture 5
  - Clinch, Jackson, Tanigawa, *Abstract 3-Rigidity and Bivariate C¹₂-Splines
    II*, Discrete Analysis 2022:3
  - White, Whiteley, *The Algebraic Geometry of Stresses in Frameworks*, SIAM J.
    Alg. Disc. Meth. 4 (1983), 481–511

## The formalization

- `DongzheZheng/Kiraly-Tanigawa-Body-Pin-Rigidity-Conjecture`, pinned here as
  the `formalization/` submodule at `afdfb9fc8f28abc4feb5dcee31ae04082922ceb7`
  (tag `v1.0.0`, released 2026-08-16).
- `CITATION.cff` present: "Three-dimensional body--pin rigidity: a Lean 4
  formalization", version 1.0.0.
- Lean `4.29.0`, mathlib `8a178386ffc0f5fef0b77738bb5449d50efeea95`.
- 125 modules under `RB31EndToEnd/`, 35,223 lines, 1,851 declarations.
- **No `LICENSE` file, no copyright headers in any module, no licence mention in
  `README.md` or `CITATION.cff`.** All rights reserved by default.
  **Open question for the author:** would he add a licence? Meanwhile: submodule
  only, never vendor.
- The paper's acknowledgements and the note both credit OpenAI Codex
  (GPT-5.6 Sol) with assisting proof organization, the Lean formalization and
  its verification, typesetting, and proofreading. Worth stating plainly
  somewhere in the front matter, since it is relevant to how a reader should
  weigh the artifact.

## Checked against primary sources

The blueprint currently takes most of its historical claims from Zheng's own
§1, which is normal practice but is not the same as having checked them. What
has actually been verified against a primary source, and what has not:

All four sources below were read directly, from copies held locally and not
committed. The record here is the durable part: it is what lets a reader who
does not have the PDFs see which claims rest on a primary source.

*Asimow–Roth 1978, checked 2026-08-27.* The `asimow_roth` node was wrong and has
been rewritten. What they actually prove:

- A *regular point* of the edge function is defined (§2) as a placement at which
  the derivative attains $\max_x \operatorname{rank} \mathrm{d}f(x)$. This is
  literally the formalization's maximum-rank notion, which is worth knowing:
  `genericRigidityRank` is the literature's own definition, not a substitute for
  a genericity theory the project lacked.
- Regular points are a dense open subset of $\mathbb{R}^{nv}$, singular set of
  Lebesgue measure zero, because $P(x) = \sum (k \times k \text{ minors})^2$ is
  a nontrivial polynomial (§3).
- The theorem of §3 is a *rank equality*, not the "rigidity coincides with
  infinitesimal rigidity" slogan the node used to state: at a regular point $p$
  with $m = \dim p$ the affine-hull dimension, $G(p)$ is rigid in
  $\mathbb{R}^n$ iff $\operatorname{rank} \mathrm{d}f_G(p) = nv - (m+1)(2n-m)/2$.
- Corollary 2: rigid at one regular point implies rigid at every regular point.
  This is what makes rigidity a property of the graph, and it is the load-bearing
  half of the citation.

*Király–Tanigawa 2019, Conjecture 5, checked 2026-08-27.* Handbook chapter 20,
§20.3.5, printed pages 435–459. Statement confirmed and identical to Zheng's
Theorem 1.1 modulo the expansion step: $\sum h_G(X,X') \ge 6(|\mathcal{P}|-1)$
with capacities 6/5/3/0. Two things worth recording:

- They attribute it to "Jackson, Jordán and Tanigawa" jointly, without the
  independent-proposal history that JJV give.
- They remark that if $h_G$ were 6 rather than 5 at $d_G = 2$, the condition
  would be the Tutte–Nash-Williams condition for $3G$ to contain six
  edge-disjoint spanning trees. That is a good way to see what the capacity 5 is
  doing, and it belongs in Chapter 01 or the glossary eventually.

*Jackson–Jordán–Villányi 2026, checked 2026-08-27.* Full PDF, not the truncated
arXiv HTML.

- Conjecture 7.6 confirmed verbatim, and it uses $\ell_H$ with exactly the four
  cases Zheng uses. So the notation is inherited, not coined — noted on
  `pin_capacity`.
- §7.2's body–pin graph definition confirmed, including the $d_H(w)+4$ bound.
- Theorem 7.7 (the $C^1_2$-cofactor version of Conjecture 7.6) and Theorem 7.8
  ($\mathrm{dof}^1_2(G_H) = \max_{\mathcal{P}} \mathrm{val}_H(\mathcal{P})$,
  the min–max formula) confirmed.
- The attribution is now first-hand rather than a report of a report: "A
  conjectured characterisation of body-pin graphs which are rigid in $R^3$ was
  posed independently by the first two authors and Tanigawa in 2009 and 2011,
  respectively. It was eventually published in 2019 by Király and Tanigawa
  [14, Conjecture 5]." The first two authors are Jackson and Jordán.

*Still unchecked.* Everything else in the reference list. Nothing currently
turns on it — the four above are the ones the front matter and Chapter 01 lean
on. Chapters 02 to 04 (Phase 2) added no new citations: every result they state
is the paper's, and the only outside work they touch is the construction
theorem the formalization carries, which the paper does not cite and which this
repository therefore does not cite either. See `notes/questions.md` on its
naming.

## What the root theorem uses

`scripts/reachable.lean` walks the constant dependencies of
`RB31E2E.endToEndBodyPinStatement` and reports, per module, what the root
theorem reaches. Run once against submodule `afdfb9f` on 2026-08-27: 1,385 of
2,555 declarations, with ten modules contributing nothing. The full table, the
method, and the two `correspondence.toml` errors it caught are in
`notes/reachability.md`. This matters for attribution in one direction only —
it says what the formalization's proof rests on, and so what a reader auditing
the artifact has to read — and it says nothing about what any module is worth.

## Citation keys

`lowerCamelSurname` + year, with a trailing letter when one pair of authors has
two entries in a year (`clinchJacksonTanigawa2022a` / `...2022b`). Three
non-paper keys: `zheng2026` (the paper), `zheng2026note` (the research note),
`zheng2026lean` (the Lean development, from its `CITATION.cff`). Never cite by
the paper's bracketed number — it moves between revisions for the same reason
result numbers do.

Two `Citable` shape decisions worth knowing when adding entries, both forced by
upstream (see `notes/upstream.md` §4):

- Monographs go in as `article` with the series in the journal slot and the
  series number in the volume slot; there is no `book` constructor.
- Authors are written initials-first (`L. Asimow`), because inline citations
  abbreviate to the *last word* of a name.

## Still to do

- [x] Transcribe the paper's 31 references into `Bibliography.lean` (Phase 1).
      All 31 present, plus the paper, the note, and the formalization.
- [x] Decide citation key scheme.
- [x] Draft the README / Introduction scope statement wording (Phase 1: the
      front matter of `BodyPinBlueprint.lean`, and `README.md`).
- [ ] Ask the author about the licence and about an arXiv version. Bryan has an
      open thread.

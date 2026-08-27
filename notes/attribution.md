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

- <https://denzelzheng.com/blog/body-pin-rigidity-collinearity-flags/>,
  20 August 2026. © Dongzhe (Denzel) Zheng, no licence stated.
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

## Still to do

- [ ] Transcribe the paper's 31 references into `Bibliography.lean`, starting
      with the four above.
- [ ] Decide citation key scheme.
- [ ] Draft the README / Introduction scope statement wording.

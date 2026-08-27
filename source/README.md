# The informal source

This directory holds the paper this blueprint maps. **Its contents are
deliberately not committed** — the paper is © Zheng with no licence stated, and
this repository is unofficial exposition. Only this README is tracked.

Populate it before writing any chapter prose:

```
source/paper.pdf   the paper as distributed
source/paper.txt   pdftotext -layout output, for transcribing witnesses
```

Run `bash ./scripts/check-source.sh` to verify what you have and regenerate the
text layer.

## Why the text layer matters

Every `paper`-tagged blueprint node carries a `tex` witness block holding the
paper's statement verbatim. There is no LaTeX source for this paper, so those
witnesses are hand-transcribed, and no harness check can score them against an
upstream file (see `AGENTS.md`, "No TeX source"). Transcribing from
`source/paper.txt` rather than by eye from a rendered page removes the main
source of error. A witness that misquotes the paper is worse than no witness.

## Third-party reference PDFs

Copies of the paper's own references, when one is needed to check a claim, go in
`source/references/`. That directory is gitignored like the rest of `source/`,
and carries its own `AGENTS.md` with the conventions for it.

## Obtaining the paper

DOI `10.13140/RG.2.2.17830.28485` (ResearchGate). There is no arXiv version as
of 2026-08-27.

## Version

The correspondence table is version-specific: section and result numbering
shifts between preprint revisions. The version mapped by `correspondence.toml`
is

    zheng-2026-body_pin_partition_collinearity_flag_en_20260816.pdf
    649632 bytes
    sha256 c3cbf64f8bbb719bd886fd940af5474b821d7e598af8e087d48fb345f521ab43

`scripts/check-source.sh` checks `source/paper.pdf` against the hash recorded in
`correspondence.toml`. If it mismatches, do not proceed on the assumption that
the numbering still lines up — re-check the entries before citing them.

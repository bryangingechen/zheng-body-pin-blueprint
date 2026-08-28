# Style

Read before writing blueprint prose. The mechanics — witnesses, tags, citations,
roles — are in `AGENTS.md` next to this file; this is only about register.

## Calibrate against the sources, not against taste

The papers this blueprint describes are in `source/` (gitignored; see
`source/references/AGENTS.md`). They are the register to match, and they are
sitting right there in plain text. Grep them before inventing a formulation:

```bash
grep -n "Note that\|It follows\|We shall\|To this end" source/references/*.txt
```

What that turns up is uniformly plain and declarative:

> Our next corollary makes precise the appealing idea that a graph with too few
> edges can almost never be rigid. — Asimow–Roth 1978, §4

> We shall prove that the following $C^1_2$-cofactor version of Conjecture 7.6
> holds. In view of Conjecture 1.4, this gives strong evidence in support of
> Conjecture 7.6. — Jackson–Jordán–Villányi 2026, §7.2

> Note that, if $h_G$ were defined to be $h_G(X, X') = 6$ for $d_G(X, X') = 2$,
> then the combinatorial condition is equivalent to the Tutte–Nash-Williams
> condition. — Király–Tanigawa 2019, §20.3.5

Transitions are functional: *Note that*, *It follows that*, *To this end*, *In
connection with*, *We first*. Judgements are concrete and hedged where they
should be: *makes precise the appealing idea*, *gives strong evidence in support
of*. There are no metaphors, no mission statements, and no sentences whose job
is to tell the reader that something matters.

## What has actually gone wrong here

Every item below was written into this repository and then removed. They are the
failure modes to watch for, not hypotheticals.

| Written | Problem | Replaced with |
|---|---|---|
| "The bridge between them is the Asimow–Roth theorem… Making that seam visible is the first job of this blueprint." | metaphor, then a mission statement | "The two are related by the Asimow–Roth theorem, which the paper cites and the formalization does not contain." |
| "What that buys is the next statement…" | *what X buys is Y* | "Their theorem is stated next." |
| "That special case is worth keeping in mind, because…" | telling the reader what to think | deleted; the preceding sentence already says it |
| "Section 2.2 is the engine of the induction." | metaphor | "Section 2.2 compares the self-stress spaces of $F$ and $F - v$…" |
| "None of this is a workaround." | defensive framing of a claim nobody made | deleted |
| "The value 5 at two pins is the whole difficulty." | unsupported emphasis | the cited Király–Tanigawa observation, stated plainly |
| "…which is the point." | rhetorical closer | deleted |

## Rules

- **Say who does what.** *Lean* is a language; it does not keep, follow, index
  or prove anything. The agent is *the formalization*, *the Lean development*,
  *the paper*, or a named declaration. "Lean keeps pins as occurrences" is
  wrong; "the formalization represents $H$ as a type of pins together with two
  endpoint maps" is right. *In Lean*, *stated in Lean*, *the Lean definition*
  are all fine — those are not agentive.
- **Define a term before using it, or do not use it.** "No provenance is lost"
  used a word this blueprint had never defined. Vocabulary from the
  formalization — *provenance flag*, *terminals*, *ghost vertex*, *payment* —
  is introduced by the table at the top of the flags chapter and by the
  Chapter 09 glossary. Before that table, spell things out.
- **No metaphors for mathematical objects or for the project.** No seams,
  bridges, engines, spines, dials, on-ramps, escape hatches.
- **Do not narrate the blueprint's purpose inside a chapter.** That belongs on
  the index page, once. A chapter says what the mathematics is.
- **Do not tell the reader what is important.** No *worth keeping in mind*, *note
  the significance*, *crucially*, *the key point is*. State the fact; if it
  matters, its consequences will show up.
- **Prefer a period to an em dash.** One appositive dash per paragraph at most.
  Piled-up asides are the most reliable tell that a sentence was generated
  rather than written.
- **Claims about provenance, intent or difficulty need a source.** See
  `AGENTS.md`, "Node bodies". If you cannot cite it, cut it.
- **Contractions, exclamations, and second person do not appear.** Neither does
  *simply*, *just*, *obviously*, or *of course*.

## Check before committing

`scripts/style-check.py` greps for the tells above and prints what it finds. It
is advisory — it cannot judge a sentence, and a hit is sometimes correct — but a
new hit is worth a second look.

```bash
python3 scripts/style-check.py
```

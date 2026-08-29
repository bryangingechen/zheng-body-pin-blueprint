# Style

Read before writing blueprint prose. The mechanics — witnesses, tags, citations,
roles — are in `AGENTS.md` next to this file; this is only about register.

The audience is a mathematician checking the formalization against the paper.
They know rigidity theory, they may know no Lean at all, and they have **not**
read the paper or the repository in detail: every chapter must be readable on
its own. Every sentence should be readable by that person for its mathematical
content, and the sentences that are genuinely about the Lean development should
say so in words that person can follow.

## Two sources, two authorities

`source/paper.txt` is the paper this blueprint documents. It is the authority
on **what is true and what is said**: witnesses quote it, claims are checked
against it, and `check-witness-prose.py` measures against it.

It is not the authority on **how to say it**, because it is machine-written.
On the dimensions where machine prose goes wrong, it goes wrong the same way
this blueprint has: it signposts *never* (`in this section`, `we shall`,
`recall that`, `note that`: all zero in 15,559 words), where the four
human-written reference papers in `source/references/*.txt` signpost
constantly. Calibrate register against the references only:

```bash
grep -n "Note that\|Recall that\|In this section\|We shall" source/references/*.txt
```

(Quote and count from `jacksonJordanVillanyi2026.txt` and
`kiralyTanigawa2019.txt`; the two Asimow–Roth files have OCR damage — use them
for structure and rhythm, not for verbatim extraction.)

What the references contain is uniformly plain and declarative:

> Our next corollary makes precise the appealing idea that a graph with too few
> edges can almost never be rigid. — Asimow–Roth 1978, §4

> We shall prove that the following $C^1_2$-cofactor version of Conjecture 7.6
> holds. In view of Conjecture 1.4, this gives strong evidence in support of
> Conjecture 7.6. — Jackson–Jordán–Villányi 2026, §7.2

> Note that, if $h_G$ were defined to be $h_G(X, X') = 6$ for $d_G(X, X') = 2$,
> then the combinatorial condition is equivalent to the Tutte–Nash-Williams
> condition. — Király–Tanigawa 2019, §20.3.5

Their stock of connectives, counted over the 50,748 words of the four reference
papers alone: *hence* (96), *thus* (95), *suppose* (61), *note that* (34), *we
may assume* (25), *therefore* (18), *it follows that* (9), *so that* (8), *in
particular* (6), *observe that* (3), *consequently* (1), *to this end* (1).
Their signposting, same corpus: *the following* (63), *for example* (14), *we
will show* (12), *we first* (12), *we shall* (9), *in this section* (6),
*recall that* (4). Judgements are concrete and hedged where they should be:
*makes precise the appealing idea*, *gives strong evidence in support of*, *a
remarkable feature of body-bar frameworks is that*. There are no metaphors, no
mission statements, and no sentences whose job is to tell the reader that
something matters.

## Duties

A ban list removes bad sentences; it does not produce the good ones. These six
duties are what a paragraph of this blueprint owes the reader, and they are
where the references differ most from machine prose. `style-check.py --report`
measures the greppable ones per chapter.

### 1. Signpost

Every chapter and every section opens by saying what it does and where it sits
in the argument, in the first person plural used for guiding the reader:

> In this section we describe a graph theoretic method for determining
> $\max\{\operatorname{rank} df_G(p)\}$ for a graph $G$ with $v$ vertices. In
> light of our previous results, this gives a purely combinatorial method for
> determining whether a graph is almost always rigid or almost always flexible
> in $\mathbb{R}^2$. — Asimow–Roth 1979, §5

> We will apply the results of the last section, taking $M$ to be the generic
> 2-dimensional rigidity matroid $R_2$ … This will allow us to introduce new
> proof techniques, which we will subsequently apply to $R_3$ and $C^1_2$, in
> the more straightforward context of $R_2$. — Jackson–Jordán–Villányi 2026, §5

> We now return to a finite loopless multigraph $H = (W, E)$ and its body–pin
> graph $G_H$.

The "we" is guidance-only: *we now return to*, *we first recall*, *we describe
next*. Who proved what stays explicit — *the paper*, *the formalization*, a
named declaration — never "we". "We prove" is wrong in this document; "we now
state what the formalization proves" is right.

### 2. Connect

Every inference in running prose carries its connective: *because*, *so*,
*since*, *thus*, *hence*, *it follows that*, *note that*. A chain of named
steps with no connective between them is an unfinished paragraph, not a concise
one. Before this rule was measured, the document used *thus* zero times in
10,452 words.

### 3. Recall

Re-gloss notation at the point of use, with an *i.e.* apposition where one
clause suffices:

> … an $R_3$-closed graph, i.e., a graph $G \subseteq K_n$ whose edge set is a
> closed set in $R_3(K_n)$. — Jackson–Jordán–Villányi 2026, §1

and restate the setup at the head of a section that returns to it, the way
Király–Tanigawa §20.3.5 rebuilds the body-pin definition from scratch although
§20.1 already defined body-bar. A quoted `tex` witness does not count as the
blueprint having defined anything: witnesses are evidence, and a reader
following the prose may skip them. Whatever the prose uses, the prose defines
or recalls in its own voice.

### 4. Rhythm

The references are bimodal: 22% of their sentences are ten words or fewer, 27%
are thirty or more. The short ones discharge steps — "The necessity of Theorem
20.1 follows from Proposition 20.3."; "We assume $E(G) \neq \emptyset$ since
otherwise the claim is trivial." — and the long ones carry constructions. This
document's failure mode is the opposite of both: too few short sentences, and
short ones used for drama rather than for a step ("The rest is short." "The
proof is the paper's."). The test for a sentence under ten words: does it state
a step or a fact the argument uses? If it is there for cadence, fuse it into
its neighbour or cut it. And a long sentence carries one construction, not
three coordinate assertions.

### 5. Motivate, in the sources' three patterns

All three are claims about the mathematics, and all three are wanted here:

- **What goes wrong otherwise.** "If a pin may connect more than two bodies,
  understanding rigidity properties … turns out to be challenging as any
  rigidity question of bar-joint frameworks can be formulated in this body-pin
  model. Thus in this subsection we shall focus on the model where each pin
  connects exactly two bodies." — Király–Tanigawa 2019, §20.3.5
- **Placement rationale.** "This will allow us to introduce new proof
  techniques … in the more straightforward context of $R_2$." — JJV 2026, §5
- **Relation to a prior result.** "It can be viewed as a local version of
  Theorem 2.6(b). Indeed, Theorem 2.6(b) follows from a combination of this
  result and Lemma 4.1." — JJV 2026, §5

Hedged, grounded evaluation is in register: *gives strong evidence in support
of*, *a remarkable feature of body-bar frameworks is that*. What stays banned
is the unhedged verdict with no fact under it (*the whole difficulty*, *the key
point*).

Narrating the **mathematics' organization** — what a section proves, why it
comes before another, what an earlier result contributes — is a duty, not a
violation. What stays out of chapters is narration of the **document as an
artifact**: the blueprint's purpose, its node conventions, what a reader will
ask or want. That belongs on the index page, once.

### 6. No definite description before its definition

*The induction*, *the flag move*, *the degree ledger*, *the bad locus* — a
definite noun phrase asserts that the reader has met the thing. Before the
thing is stated, glossed, or cross-referenced, the phrase may not appear. This
is the sharpest way the old text presumed a reader who had already read the
paper: "the induction" appeared eleven times before any statement of what was
being proved by induction, on what, with what hypothesis.

## The habit to break: naming a fact's role instead of stating the fact

This is the failure this guide exists for, and it is not a matter of taste. Two
constructions were counted 28 times across 10,449 words of blueprint prose, and
**zero** times in the 50,748 words of the human-written references:

| Written here | In the references |
|---|---|
| *X is what makes / lets / turns / does Y* | 0 occurrences |
| *X is where Y happens* | 0 occurrences |

Both wrap a plain predication in a frame that announces the fact's importance
instead of asserting it. Both are always removable, and removing one usually
shortens the sentence and forces the reason into the open:

| Before | After |
|---|---|
| "The strict decrease of the active-vertex count in front of them is what makes the disjunction a reduction rather than a rewriting." | "The definition puts a strict decrease of the active-vertex count in front of the disjunction, so it is a reduction rather than a rewriting." |
| "The local increment is where the two branches of the induction part company." | "The local increment decides which branch of the induction applies." |
| "Part (a) is where the four private vertices earn their place." | "The four private vertices that the expansion gives every body are used in part (a)." |
| "…and the `if` in its body is where the nonedges go to zero." | "…and its body sends a nonadjacent pair to zero." |
| "…which is what the capacities 3, 5, 6 count." | "…so the capacities 3, 5, 6 count occurrences, not pairs of bodies." |

**The rule: neither construction appears.** Not a budget — a rewrite exists in
every case, and the rewrite is better. `style-check.py` reports both as errors,
and `checks.sh` fails on one.

After those two were banned, the same instinct reappeared in synonyms the grep
does not match, and every one of them is the same move:

| Dodge | Example written here |
|---|---|
| *X exists to do Y* | "Everything in the flags chapter exists to carry that case through the induction." |
| *the mechanism is X, which turns Y into Z* | "The mechanism is a Witt shear …, which turns the isotropic-difference equations into the linear equations of the rigidity matrix." |
| *X is how Y is done* | "Promoting a row of this index to a node of its own is how a cluster node is later split." |
| *X, the value Y needs* | "…and that height is exactly $\|E_F\|$, the value the codimension estimate needs." |
| *X does the same work* | "The paper's 'a generic realization' does the same work in three words." |

These are warnings rather than errors while the rewrite is in progress; the
fix is the same as for the parent constructions.

One thing that looks like an exception and is not. *The register entry is in
`lt-source-deviations.toml`* is an ordinary locative rather than this
construction, and the checker does not match it. A definition can take the first
shape — *$L$ is what survives the deletion* — but the plain form is available
there too, and shorter: *$L$ is generated by the coordinates that survive the
deletion*.

The same instinct produces the cleft, *What X shows is Y*. That one is
legitimate for a genuine contrast — "What it does not show is…" — so it gets a
budget instead of a ban: at most one per section, never two in a row.

Behind all of them is a single question worth asking of any sentence: **is this
a claim about the mathematics, or a claim about the claim?** State facts. If a
fact matters, its consequences will show up on their own.

## The text is not the subject

The role-naming ban has a grammatical cousin that copulas alone do not catch:
sentences whose subject is the document — the display, the lemma, the chapter,
the node, the line count — with a declarative verb attached. "This lemma
introduces the condition $q(X) = 0$." "Both halves of the display are
declarations." "The dependency edges on this node record that." "That
construction is the rest of this section." Each is a stage direction. The fix
is the guide's oldest rule: put the mathematical object in subject position and
let the fact carry the sentence. ("For a twist to admit a solution, $q(X) = 0$
is necessary; Lemma 6.2 proves it sufficient.")

Two shapes of this to watch for specifically:

- **The identifier caption.** A paragraph whose entire content is a naming
  equation: "The paper's $u$ is `outsideResponseKernelDim`." Twelve of these
  stood in one chapter. Fuse the name into a sentence that states the
  mathematics ("…so $u$, formalized as `outsideResponseKernelDim`, counts…"),
  or drop it where the node's panel already shows the declaration.
- **The scorekeeping flourish.** The paper-versus-formalization comparison is
  the blueprint's core move and is usually right; what goes wrong is the
  closing verdict — *constantly and silently*, *does the same work in three
  words*, *never has to say anything here*. Keep the comparison, state both
  sides, drop the flourish.

## Proof-engineering idiom is not mathematics

Compare:

> The formalization gives each of the four literal edge-set semantics, on an
> ambient edge set together with an explicit active vertex set, and **closes the
> low-degree branches**.

A reader following the argument has been shown no proof, so "branches" has no
referent and "closes" no object. The words come from the experience of writing
the Lean file, and they carry none of it to the page.

Watch for: *closes* / *discharges* / *finishes* a branch or a goal; *the
caller*, *the call site*, *branches on*, *the case split*, *an excluded middle*,
*a stored tag*, *plumbing*, *machinery*, *boilerplate*, *on the nose*; also
*returns* said of a theorem, and *obligations* outside a sentence that has
already said it is describing Lean.

The test: **could a mathematician who has never used a proof assistant read the
sentence for the argument?** If not, name the mathematics.

This is not a ban on writing about the Lean development — half the deliverable
is exactly that. It is a requirement to name it precisely. *The module*, *the
declaration*, *the hypothesis*, *the definition*, *the statement of Lemma 3.4*
are all concrete and all readable. *The caller* is neither. Where the paper's
proof and the formal proof genuinely differ in structure, describe the two
arguments, not the two implementations.

## Titles are noun phrases

Every heading becomes a URL and a line in the table of contents. It names a
subject; it does not make a statement about one.

| Written | Problem | Replaced with |
|---|---|---|
| "The construction theorem the formalization carries" | a sentence with the verb removed; reads as a fragment | "A construction theorem with no paper counterpart" |

Test: read the title on its own, out of context. If it wants a full stop, it is
a sentence and needs rewriting. "Sparsity and tight sets", "Descent and the
three neighbour rows", "From a rigid graph to a rigid twist system" all pass.

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
| "This is the paper's headline result." | journalism | "This is Conjecture 5 of Király and Tanigawa (2019)." |
| "Part (a) is where the four private vertices earn their place." | role-naming, then idiom | "The four private vertices that the expansion gives every body are used in part (a)." |
| "…and this is where that costs something." | role-naming, then idiom, with no antecedent for *that* | "…so the placement has to be produced by hand." |
| "…which is where the equation $q(X) = 0$ is put to work." | role-naming, then idiom | "…and the sufficiency argument is a height estimate for the ideal those conditions generate." |
| "The one deviation worth watching is Lemma 6.3." | telling the reader what matters | "Lemma 6.3 is proved by a different route." |
| "…a reader meeting a scheme-theoretic section with no formalization will ask whether it was skipped, and the answer belongs here rather than in a footnote." | narrating the blueprint's design inside a chapter | "This chapter records what §4 claims and which part of it the formal argument uses." |
| "The rest is short." | clipped closer for cadence, no step stated | fused into the next sentence |
| "The chapter opens with a vocabulary table, because…" | narrating a layout — one that did not exist | the table, or nothing |
| "The paper changes coefficient field constantly and silently." | scorekeeping flourish | the comparison, with both sides stated |

## Rules

- **Say who does what.** *Lean* is a language; it does not keep, follow, index
  or prove anything. The agent is *the formalization*, *the Lean development*,
  *the paper*, or a named declaration. "Lean keeps pins as occurrences" is
  wrong; "the formalization represents $H$ as a type of pins together with two
  endpoint maps" is right. *In Lean*, *stated in Lean*, *the Lean definition*
  are all fine — those are not agentive. The guidance-"we" of Duty 1 guides the
  reader; it never proves, chooses, or formalizes.
- **Define a term before using it, or do not use it.** "No provenance is lost"
  used a word this blueprint had never defined. Vocabulary from the
  formalization — *provenance flag*, *terminals*, *ghost vertex*, *payment* —
  is introduced by the table at the top of the flags chapter and by the
  Chapter 09 glossary. Before that table, spell things out — and Duty 6
  applies: no *the X* before X exists.
- **No metaphors for mathematical objects or for the project.** No seams,
  bridges, engines, spines, dials, on-ramps, escape hatches. No colloquial
  idiom either: *earn their place*, *part company*, *put to work*, *on the
  nose*, *for free*, *waves through*, *leaves … behind*, *covers the same
  ground*, *with no graph in sight*.
- **Do not narrate the blueprint's purpose inside a chapter.** That belongs on
  the index page, once. A chapter says what the mathematics is. Nor speculate
  about what a reader will ask, notice, or want. This rule is about the
  document as an artifact; narrating the *mathematics'* organization is Duty 5,
  and required.
- **Do not tell the reader what is important.** No *worth keeping in mind*,
  *worth watching*, *note the significance*, *crucially*, *the key point is*,
  *headline*. State the fact. A hedged judgement grounded in a fact is fine
  (Duty 5); a bare verdict is not.
- **Prefer a period to an em dash.** One appositive dash per paragraph at most.
  Piled-up asides are the most reliable tell that a sentence was generated
  rather than written.
- **Claims about provenance, intent or difficulty need a source.** See
  `AGENTS.md`, "Node bodies". If you cannot cite it, cut it. This covers
  line-count comparisons and remarks about how hard something was: give the
  measurement and let it speak, or cut the remark.
- **Contractions, exclamations, and second person do not appear.** Neither does
  *simply*, *just*, *obviously*, or *of course*.

## When a paragraph will not come out

Three moves, in this order, before reaching for a frame.

1. **Put the mathematical object in the subject position.** Most of the
   role-naming sentences above start from a subject that is a piece of
   commentary — *the strict decrease*, *the local increment*, *part (a)* — and
   then need a copula to reach the fact. Start from the graph, the field, the
   row space, the declaration.
2. **Say the reason with *because*, *so*, *since*, *thus*, *hence*.** The
   references use nothing else. A frame gets written when the reason has not
   been worked out yet; working it out is the fix.
3. **Say where the reader is.** If neither move lands, the paragraph is usually
   missing its orientation, not its phrasing: the reader does not know what is
   being proved or why this object appears. Write the signpost sentence (Duty
   1) or the recall (Duty 3) first, and the stuck sentence usually writes
   itself.

## Check before committing

`scripts/style-check.py` greps for the tells above and prints what it finds, at
two severities, and `--report` prints the register metrics.

An **error** is one of the two banned constructions. `checks.sh` runs the script
with `--strict`, so one of those fails the fast check list and CI with it.

A **warning** is everything else — idiom, proof-engineering vocabulary, the
dodge synonyms, identifier captions, a clipped paragraph-final sentence, a
heading with a finite verb in it, three em dashes in a paragraph. Those match
strings rather than sentences, so a warning is sometimes correct and can stay:
"the bridge between two bodies" is a false positive. A *new* warning is worth a
second look. `--pedantic` fails on warnings too, which is useful while revising
one chapter and too strict for the check list. A warning family that reaches
zero legitimate uses across the document gets promoted to an error; that is how
the two error patterns earned their severity.

`--report` prints, per chapter, the sentence-length distribution and the
connective and signposting densities, against the references-only baselines
baked into the script. The report never gates; it makes drift visible.

```bash
python3 scripts/style-check.py                                    # report tells
python3 scripts/style-check.py --report                           # register metrics
python3 scripts/style-check.py BodyPinBlueprint/Chapters/Flags.lean --pedantic
```

/-
Declaration bodies, read from the pinned formalization rather than copied.

The external-declaration panel renders a signature and cannot render a value
(`notes/upstream.md` §8).  Until this module, a chapter that needed the value
quoted it in a Lean fence: a verbatim copy, elaborated a second time in the
blueprint's own environment, which meant a `-show` block of `open ... hiding`
and `variable` scaffolding for every quote, and `scripts/check-snippets.py` to
notice when the copy went stale.

SubVerso's `subverso-extract-mod` removes all of that.  It re-elaborates a
module of the formalization and emits, per command, a `ModuleItem` carrying the
names the command defines and its `Highlighted` code -- Verso's own type, so it
renders with the same colours, hovers and cross-links as any other Lean block.
`scripts/extract-bodies.sh` runs it over the modules the nodes actually name and
leaves the JSON in `.lake/build/highlighted/`; this module reads it back.

Nothing is copied into the repository, nothing is elaborated twice, and no copy
can go stale: the text is the pinned submodule's own source, extracted at build
time.  Measured against the eleven hand-quoted declarations that could be
compared, the extractor reproduced every one byte for byte.
-/
import VersoManual
import SubVerso.Module

open Lean
open Verso Verso.Doc.Elab Verso.ArgParse
open Verso.Genre.Manual
open Verso.Code.External Verso.Code.External.ExternalCode
open SubVerso.Highlighting

namespace BodyPinBlueprint

/-- Where `scripts/extract-bodies.sh` leaves SubVerso's per-module JSON. -/
def extractRoot : System.FilePath := ".lake" / "build" / "highlighted"

/-- `RB31EndToEnd.Rigidity.BarJoint` ↦ `.lake/build/highlighted/RB31EndToEnd/Rigidity/BarJoint.json` -/
def modulePath (mod : Name) : System.FilePath :=
  mod.components.foldl (fun p c => p / c.toString) extractRoot |>.addExtension "json"

/-- The module a declaration was compiled from. -/
def moduleOf? (env : Environment) (decl : Name) : Option Name :=
  match env.getModuleIdxFor? decl with
  | some idx => env.header.moduleNames[idx.toNat]?
  | none => none

/--
The extracted items of one formalization module.

Reading is not cached: a module's JSON is a few hundred kilobytes and the
document names seventy-two declarations, of which forty-one are quoted, so the
cost is not worth a cache that could serve a stale parse.
-/
def loadItems (mod : Name) : IO (Array SubVerso.Module.ModuleItem) := do
  let path := modulePath mod
  unless ← path.pathExists do
    throw <| .userError <|
      s!"No extracted bodies for {mod}: {path} is missing.\n" ++
      "Run `bash ./scripts/extract-bodies.sh` (about 45 minutes cold, cached after)."
  let .ok json := Json.parse (← IO.FS.readFile path)
    | throw <| .userError s!"{path} is not JSON"
  let .ok (m : SubVerso.Module.Module) := fromJson? json
    | throw <| .userError s!"{path} is not a SubVerso module extract"
  return m.items

/-- The extracted command that defines `decl`. -/
def bodyOf? (env : Environment) (decl : Name) :
    IO (Except String SubVerso.Module.ModuleItem) := do
  let some mod := moduleOf? env decl
    | return .error s!"{decl} is not from an imported module"
  let items ← loadItems mod
  let some item := items.find? (·.defines.contains decl)
    | return .error s!"{mod} defines no {decl}; is the extract older than the submodule pin?"
  return .ok item

/--
A `where` field is a proof obligation exactly when its projection lands in
`Prop`, and that is a question about the projection rather than about the text.

`SimpleGraph.Adj` and `SimpleGraph.symm` are both written `field := ...` in a
`where` block, and `Adj`'s result type is `Prop` while `symm`'s is
`Symmetric self.Adj`.  What separates them is that `Symmetric ...` *is* a
proposition and `Prop` is not one -- `Prop : Type` -- which is exactly what
`Meta.isProp` asks.  Eliding by syntax instead would be wrong in both
directions: `rigidityOperator` and `genericRigidityRank` are data given by `by`
blocks.

Field names arrive already resolved by SubVerso, so the parent chain costs
nothing here: a `LinearMap` written with `where` names `AddHom.toFun` and
`AddHom.map_add'`, not `LinearMap.toFun`.
-/
def isObligation (proj : Name) : MetaM Bool := do
  let some ci := (← getEnv).find? proj | return false
  Meta.forallTelescopeReducing ci.type fun _ body => Meta.isProp body

/-- Is this command's value a `where` block? -/
partial def usesWhere : Highlighted → Bool
  | .seq xs => xs.any usesWhere
  | .span _ x | .tactics _ _ _ x => usesWhere x
  | .token ⟨.keyword _ (some occ) _, _⟩ =>
    occ.startsWith "Lean.Parser.Command.whereStructInst"
  | _ => false

/--
The constant each `const` token names, by character offset into `toString`.

`Highlighted.toString` concatenates the leaves in order and nothing else, so an
offset into it is an offset into the text a parse of that string sees.  That is
what lets a field's identifier in the reparsed tree be matched to the name
elaboration already gave it.

Characters rather than bytes, because a `String.Pos` in this toolchain is
indexed by its own string and carries a proof that it is valid for it, so a raw
byte index cannot be turned back into one.  The parser reports bytes;
`charOffset` converts.
-/
partial def constTokens (hl : Highlighted) : Array (Nat × Name) :=
  (go hl 0 #[]).2
where
  go (hl : Highlighted) (pos : Nat) (acc : Array (Nat × Name)) : Nat × Array (Nat × Name) :=
    match hl with
    | .seq xs => xs.foldl (init := (pos, acc)) fun s x => go x s.1 s.2
    | .span _ x | .tactics _ _ _ x => go x pos acc
    | .point .. => (pos, acc)
    | .token ⟨k, s⟩ =>
      let acc := match k with
        | .const n .. => acc.push (pos, n)
        | _ => acc
      (pos + s.length, acc)
    | .text s | .unparsed s => (pos + s.length, acc)

/-- The fields of a `where` block, not descending into their values. -/
private partial def whereFields (stx : Syntax) : Array Syntax :=
  if stx.getKind == ``Lean.Parser.Command.whereStructInst then fields stx #[]
  else stx.getArgs.foldl (init := #[]) fun acc c => acc ++ whereFields c
where
  fields (stx : Syntax) (acc : Array Syntax) : Array Syntax :=
    if stx.getKind == ``Lean.Parser.Term.structInstField then acc.push stx
    else stx.getArgs.foldl (init := acc) fun a c => fields c a

/-- The value of a `where` field: the term after `:=`, or the alternatives. -/
private def fieldValue? (f : Syntax) : Option Syntax :=
  let decl := f[1][2]
  if decl.getKind == ``Lean.Parser.Term.structInstFieldDef then some decl[2]
  else if decl.getKind == ``Lean.Parser.Term.structInstFieldEqns then some decl[1]
  else none

/-- The character offset of a byte offset, which is what the parser reports. -/
private def charOffset (src : String) (byte : Nat) : Nat := Id.run do
  let mut bytes := 0
  let mut chars := 0
  for c in src.toList do
    if bytes ≥ byte then return chars
    bytes := bytes + c.utf8Size
    chars := chars + 1
  return chars

/--
Character ranges of the values of the `Prop`-valued `where` fields of one
command.

The command is reparsed from its own rendered text.  That is sound because
`Highlighted.toString` reproduces the source exactly, and it is necessary
because the extract carries tokens rather than a tree: a field's `:=` is an
ordinary token with no binding, so nothing short of a parse says where one field
stops and the next begins.  It is also the *only* place a parse is needed --
`quotedBodyJs` finds the boundary between a header and its value from a
keyword's recorded production, which needs none.

Only a `where` declaration is reparsed, so a failure is worth reporting rather
than swallowing: it would otherwise show as a body that quietly kept its proofs.
-/
def obligationRanges (src : String) (consts : Array (Nat × Name)) :
    MetaM (Except String (Array (Nat × Nat))) := do
  let .ok stx := Parser.runParserCategory (← getEnv) `command src
    | return .error "it does not reparse"
  let mut out : Array (Nat × Nat) := #[]
  for f in whereFields stx do
    let some lval := f[0].getPos? | continue
    let some (_, proj) := consts.find? (·.1 == charOffset src lval.byteIdx) | continue
    unless ← isObligation proj do continue
    let some value := fieldValue? f | continue
    let some a := value.getPos? | continue
    let some b := value.getTailPos? | continue
    out := out.push (charOffset src a.byteIdx, charOffset src b.byteIdx)
  return .ok out

/-- The characters of `s` from `a` to `b`, both counted from the whole text. -/
private def slice (s : String) (base a b : Nat) : String :=
  SubVerso.Compat.String.take (SubVerso.Compat.String.drop s (a - base)) (b - a)

/-- Keeps the part of one leaf that no range covers, marking each range once. -/
private partial def cut (ranges : Array (Nat × Nat)) (mk : String → Highlighted)
    (s : String) (base cur stop idx : Nat) : Highlighted × Nat :=
  if cur ≥ stop then (.empty, idx)
  else match ranges[idx]? with
    | none => (mk (slice s base cur stop), idx)
    | some (a, b) =>
      if b ≤ cur then cut ranges mk s base cur stop (idx + 1)
      else if cur < a then
        let e := min a stop
        let (rest, i) := cut ranges mk s base e stop idx
        (mk (slice s base cur e) ++ rest, i)
      else
        let e := min b stop
        let (rest, i) := cut ranges mk s base e stop idx
        ((if cur == a then Highlighted.text "⋯" else .empty) ++ rest, i)

/--
Does anything survive that a tactic state or a message could annotate?

A `.tactics` node carries the goal state of a `by` block, and Verso renders it
as a toggle whose label is the block's own text.  Elide that text and the
wrapper is still there, so the `⋯` *becomes* the toggle: clicking it expands the
proof state the elision was there to remove.  `bodyClique` escaped only by
accident -- its `loopless` value is `⟨by ...⟩`, so the range starts at the `⟨`,
outside the tactics node, and the node is consumed whole.  `connectingMap` and
`directionEquilibrium` write `map_add' := by ...` and did not escape.

A range covers a whole field value and a tactics node sits inside one, so the
node is either untouched or covered entirely; "no token left" is therefore the
same question as "the proof text is gone", and the wrapper has nothing left to
annotate.  The same holds of a `.span`, which carries messages.
-/
private partial def annotatable : Highlighted → Bool
  | .seq xs => xs.any annotatable
  | .span _ x | .tactics _ _ _ x => annotatable x
  | .token .. => true
  | _ => false

private partial def elideGo (ranges : Array (Nat × Nat)) (hl : Highlighted) (pos idx : Nat) :
    Highlighted × Nat × Nat :=
  match hl with
  | .seq xs =>
    let (out, p, i) := xs.foldl (init := ((#[] : Array Highlighted), pos, idx))
      fun s x =>
        let (y, p, i) := elideGo ranges x s.2.1 s.2.2
        (s.1.push y, p, i)
    (.seq out, p, i)
  | .span info x =>
    let (y, p, i) := elideGo ranges x pos idx
    (if annotatable y then .span info y else y, p, i)
  | .tactics info a b x =>
    let (y, p, i) := elideGo ranges x pos idx
    (if annotatable y then .tactics info a b y else y, p, i)
  | .point .. => (hl, pos, idx)
  | .token ⟨k, s⟩ =>
    let stop := pos + s.length
    let (y, i) := cut ranges (fun str => .token ⟨k, str⟩) s pos pos stop idx
    (y, stop, i)
  | .text s =>
    let stop := pos + s.length
    let (y, i) := cut ranges .text s pos pos stop idx
    (y, stop, i)
  | .unparsed s =>
    let stop := pos + s.length
    let (y, i) := cut ranges .unparsed s pos pos stop idx
    (y, stop, i)

/-- Replaces each character range with `⋯`. Ranges must be sorted and disjoint. -/
def elide (ranges : Array (Nat × Nat)) (hl : Highlighted) : Highlighted :=
  if ranges.isEmpty then hl else (elideGo ranges hl 0 0).1

/--
One extracted command with its proof obligations elided, and what went wrong if
anything did.

A declaration with no `where` block is returned untouched, which is all but
three of the declarations the chapters quote -- `bodyClique`, `connectingMap`
and `directionEquilibrium` are the exceptions -- so the reparse happens only
where it can pay for itself.
-/
def elidedCode (item : SubVerso.Module.ModuleItem) :
    MetaM (Highlighted × Option String) := do
  unless usesWhere item.code do return (item.code, none)
  match ← obligationRanges item.code.toString (constTokens item.code) with
  | .error e => return (item.code, some e)
  | .ok ranges => return (elide ranges item.code, none)

/--
Renders the body of each declaration named in the block, one Lean block apiece.

    ```bodies
    RB31E2E.Sparse22
    RB31E2E.Tight22
    ```

A name must be imported by the chapter, and its module must have been extracted.
Both failures are elaboration errors naming what to do, because a body that
silently did not appear would be indistinguishable from one a node never asked
for.

Proof obligations render as `⋯`. A definition written with `where` states its
data and its obligations in the same list, and the obligations are usually most
of it: `bodyClique` is three lines of adjacency and five of `symm` and
`loopless`. Eliding them is the same move `pp.proofs` makes, and it is visibly
an omission rather than a change -- which is what makes it safe to do to source
this repository does not own.

The omission has to be total, which is why `annotatable` above drops a
`.tactics` wrapper the elision emptied. A `by`-block obligation would otherwise
keep its goal state and the `⋯` would be the toggle that expands it. A `by`
block that is the *value* keeps its toggle, as `rigidityOperator` and
`genericRigidityRank` do: those are data, and nothing about them is elided.

`defSite := true` is load bearing rather than cosmetic. It sets Verso's
`definitionsAsTargets`, which is what puts an `id` on the token that defines a
constant (`Token.Kind.idAttr`), and that `id` is how `quotedBodyJs` tells which
declaration a rendered block belongs to. Extracted names are fully qualified,
so the join is exact. The mechanism this replaced had to guess: a hand-quoted
block declared `Sparse22` where the panel named `RB31E2E.Sparse22`, and the
match was made on a unique dotted suffix.
-/
@[code_block_expander bodies]
def bodies : CodeBlockExpander
  | _args, str => do
    let env ← getEnv
    let names := str.getString.splitOn "\n"
      |>.map (·.trimAscii.copy) |>.filter (fun l => !l.isEmpty && !l.startsWith "--")
    if names.isEmpty then
      throwErrorAt str "No declaration names given"
    let mut out := #[]
    for n in names do
      let decl := n.toName
      match ← bodyOf? env decl with
      | .error e => throwErrorAt str e
      | .ok item =>
        let (code, warn?) ← elidedCode item
        if let some e := warn? then
          logWarningAt str m!"Proof obligations of {decl} are not elided: {e}"
        out := out.push <|
          ← ``(leanBlock $(quote code) $(quote ({ defSite := some true } : CodeConfig)))
    return out

end BodyPinBlueprint

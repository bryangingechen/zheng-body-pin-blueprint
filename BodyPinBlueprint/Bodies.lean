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
document names sixty-two declarations, so the cost is not worth a cache that
could serve a stale parse.
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
Renders the body of each declaration named in the block, one Lean block apiece.

    ```bodies
    RB31E2E.Sparse22
    RB31E2E.Tight22
    ```

A name must be imported by the chapter, and its module must have been extracted.
Both failures are elaboration errors naming what to do, because a body that
silently did not appear would be indistinguishable from one a node never asked
for.

`defSite := true` is load bearing rather than cosmetic. It sets Verso's
`definitionsAsTargets`, which is what puts an `id` on the token that defines a
constant (`Token.Kind.idAttr`), and that `id` is how `quotedBodyJs` tells which
declaration a rendered block belongs to. Extracted names are fully qualified,
so the join is exact -- the dotted-suffix guess a hand-quoted block needed,
because it declared `Sparse22` where the panel named `RB31E2E.Sparse22`, is not
needed here.
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
        out := out.push <|
          ← ``(leanBlock $(quote item.code) $(quote ({ defSite := some true } : CodeConfig)))
    return out

end BodyPinBlueprint

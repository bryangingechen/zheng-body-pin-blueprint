/-
Project CSS, passed to the generator as `RenderConfig.extraCss`.

Verso's `HtmlAssets.extraCss` is "extra CSS to be included inline into every
`<head>` via `<style>` tags"; the config's copy is merged into the traverse
state when it is initialised, so a project can style its own pages without
patching VersoBlueprint or post-processing the output.  Both entry points pass
it, so the site and `scripts/preview.py` agree.

The two builds render a quoted body differently.  The site elaborates the fence
and emits `<code class="hl lean block">`; the preview strips the fence, because
it has no formalization to resolve names against, and emits an unclassed
`<pre>`.  The rule below names both, so the preview is a fair picture of where a
block sits and how heavy it looks.

They differ in one visible way, and it is the site that shows less.  Verso's
highlighter drops comments -- there is not one `.comment` span anywhere on the
built site -- so the `-- <path>` first line of every quoted body is invisible
there, while the preview keeps it as ordinary text.  That line is a marker for
`scripts/check-snippets.py`, not something the reader ever sees on the site; a
reader who wants the file follows the source link on the declaration panel
beside the block.  A caption rule styling that first line was written here and
removed once the built page showed it matches nothing.

Everything here uses VersoBlueprint's own `--bp-color-*` tokens, defined in
`VersoBlueprint/Commands/Common.lean`.  Matching the declaration panel means
reusing its variables rather than guessing hex values, and it keeps this file
correct if upstream restyles.
-/

namespace BodyPinBlueprint

/--
Styling for the quoted upstream definitions.

These blocks exist only because the external-declaration panel cannot render a
definition's body (`notes/upstream.md` §8), so they always sit next to a panel
that carries the same declaration's signature.  Left unstyled they read as loose
code dropped into the prose.  This gives them the panel's own surface and border
so the pair reads as one apparatus.

`code.hl.lean.block` is what an elaborated Lean block renders as; a panel
signature is a `pre` carrying the same `hl lean block` classes and is left
alone.  `pre:not([class])` is the preview's form of the same blocks: in a
preview render those are the only unclassed `pre` elements, and on the real site
there are none, so the selector is exact in both.
-/
def quotedBodyCss : String := r##"
code.hl.lean.block,
pre:not([class]) {
  display: block;
  overflow-x: auto;
  margin: 1rem 0;
  padding: 0.7rem 0.85rem;
  background: var(--bp-color-surface-muted);
  border: 1px solid var(--bp-color-border-soft);
  border-left: 3px solid var(--bp-color-border-strong);
  border-radius: 0.25rem;
  line-height: 1.45;
}
"##

end BodyPinBlueprint

/-
Hand-authored inline SVG figures.

The paper has three figures. The author's published SVGs cannot be embedded --
they are flattened path data with hardcoded `rgb()` colours, no text elements,
and © with no licence (`PLAN.md`, decisions table) -- so each figure is redrawn
by hand and carried in its chapter's own source, inside a

    ```BodyPinBlueprint.svgFigure (alt := "one-sentence description")
    <svg viewBox="..." ...>...</svg>
    ```

fence.  The expander checks the content is a single `<svg>` element with no
script and no event handler, and the block extension emits it verbatim inside a
`<figure role="img">`.  There is no image file, no external fetch, and nothing
for a build to lose: the drawing is source, in the chapter it illustrates, and
`scripts/preview.py` renders it unchanged because nothing here touches the
formalization.

Theme awareness is the reason the figures are drawn with `currentColor`: every
stroke and every label inherits the page's text colour, so the same drawing
reads on the light and dark palettes.  The two body fills and the two edge
accents that need a hue of their own take it from the CSS below at low opacity,
so they sit on either background; everything else is `currentColor` in the SVG
itself.
-/
import VersoManual

open Lean
open Verso Verso.ArgParse Verso.Doc Verso.Doc.Elab
open Verso.Genre.Manual

namespace BodyPinBlueprint

/--
Styling shared by the three figures.  Strokes and text inherit `currentColor`
in the SVG source; only the classes below carry a hue, and each is translucent
so it works on both palettes.  The class names are referenced from the SVG
markup in the chapters.
-/
def figureCss : String := r##"
figure.bpx_figure {
  margin: 1.75rem auto;
  text-align: center;
  max-width: 100%;
  overflow-x: auto;
}

figure.bpx_figure svg {
  max-width: 100%;
  height: auto;
  font-family: inherit;
}

figure.bpx_figure text {
  fill: currentColor;
}

/* The two bodies of the capacity figure: the paper draws them blue and
   orange.  Translucent fills read on light and dark alike. */
figure.bpx_figure .bpx_fig_bodyA { fill: #4f83cc; fill-opacity: 0.32; }
figure.bpx_figure .bpx_fig_bodyB { fill: #e08b3c; fill-opacity: 0.32; }

/* Edge accents for the flag figure: the restored edge and the auxiliary
   star.  Solid hues, since a line has no area to be translucent over. */
figure.bpx_figure .bpx_fig_restored { stroke: #3572b0; }
figure.bpx_figure .bpx_fig_auxiliary { stroke: #d07a2a; }
figure.bpx_figure .bpx_fig_restored_text { fill: #3572b0; }
figure.bpx_figure .bpx_fig_auxiliary_text { fill: #d07a2a; }
"##

def Block.svgFigure (alt : String) (svg : String) : Verso.Genre.Manual.Block where
  name := `BodyPinBlueprint.Block.svgFigure
  data := ToJson.toJson (alt, svg)

@[block_extension Block.svgFigure]
def svgFigure.descr : BlockDescr where
  traverse _ _ _ := pure none
  extraCss := [figureCss]
  toTeX := none
  toHtml := some fun _goI _goB _id info _contents =>
    open Verso.Doc.Html HtmlT in
    open Verso.Output Html in do
      let .ok ((alt, svg) : String × String) := FromJson.fromJson? info
        | do logError "Failed to deserialize SVG figure data"; pure .empty
      return {{
        <figure class="bpx_figure" role="img" aria-label={{alt}}>
          {{Html.text false svg}}
        </figure>
      }}

structure FigureConfig where
  /-- One-sentence description of the drawing, for `aria-label`. -/
  alt : String

section
variable {m : Type → Type} [Monad m] [MonadError m]

def FigureConfig.parse : ArgParse m FigureConfig :=
  FigureConfig.mk <$> .named `alt .string false

instance : FromArgs FigureConfig m := ⟨FigureConfig.parse⟩

end

/--
A hand-drawn figure, carried as inline SVG in the chapter source.

The content must be a single `<svg>` element.  It is emitted verbatim -- raw
markup, exactly what makes this fence able to draw at all -- so the expander
refuses anything with a script or an event handler in it, and anything that is
not one `<svg>` element from start to end.  The figures are this repository's
own drawings; the check is there so the fence cannot quietly become a general
raw-HTML hole.
-/
@[code_block_expander svgFigure]
def svgFigure : CodeBlockExpander
  | args, str => do
    let cfg ← parseThe FigureConfig args
    if cfg.alt.trimAscii.isEmpty then
      throwErrorAt str "The figure needs a non-empty alt text"
    let svg := str.getString.trimAscii.copy
    unless svg.startsWith "<svg" && svg.endsWith "</svg>" do
      throwErrorAt str "Expected a single <svg>...</svg> element"
    let lowered := svg.toLower
    for banned in ["<script", "onload", "onclick", "onerror", "href=", "<foreignobject"] do
      if (lowered.splitOn banned).length > 1 then
        throwErrorAt str s!"An SVG figure may not contain {banned}"
    return #[← ``(Verso.Doc.Block.other
      (Block.svgFigure $(quote cfg.alt) $(quote svg)) #[])]

end BodyPinBlueprint

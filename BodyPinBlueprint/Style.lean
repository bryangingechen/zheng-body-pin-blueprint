/-
Project CSS and JavaScript, passed to the generator as `RenderConfig.extraCss`
and `RenderConfig.extraJs`.

Verso's `HtmlAssets` describes both as "extra CSS/JS to be included inline into
every `<head>`" via `<style>` and `<script>` tags; the config's copies are
merged into the traverse state when it is initialised, so a project can style
and script its own pages without patching VersoBlueprint or post-processing the
output.  Both entry points pass both, so the site and `scripts/preview.py`
agree.

The two builds render a quoted body differently.  The site reads the declaration
out of the pinned submodule's extract and emits `<code class="hl lean block">`;
the preview has no formalization to resolve the name against, so it drops the
block entirely.  The block rule still names the unclassed `<pre>` a plain fence
produces, so the preview remains a fair picture of where such a block sits and
how heavy it looks.  A preview render has no declaration panels either, so
`quotedBodyJs` does nothing there and the fast loop is unaffected.

One thing the built page silently omits: Verso's highlighter drops comments --
there is not one `.comment` span anywhere on the site -- so an ordinary `--`
comment inside an extracted declaration renders as nothing.  A docstring is not
a comment and does survive.  A caption rule for the `-- <path>` line that quoted
bodies used to carry was written here and removed once the built page showed it
matches nothing; the bodies no longer carry that line at all, and a reader who
wants the file follows the source link on the declaration panel.

Everything here uses VersoBlueprint's own `--bp-color-*` tokens, defined in
`VersoBlueprint/Commands/Common.lean`.  Matching the declaration panel means
reusing its variables rather than guessing hex values, and it keeps this file
correct if upstream restyles.  Check specificity against the rule being
competed with rather than assuming: a bare `.bpx_body_quoted` scores (0,1,0)
and loses to `code.hl.lean.block` at (0,3,1), which is why the selectors below
repeat the block's classes.
-/

namespace BodyPinBlueprint

/--
Styling for `quotedBodyJs` and for the quoted blocks it leaves in the prose.

`code.hl.lean.block` is what an elaborated Lean block renders as; a panel
signature is a `pre` carrying the same `hl lean block` classes and is left
alone.  `pre:not([class])` is the preview's form of the same blocks: in a
preview render those are the only unclassed `pre` elements, and on the real site
there are none, so the selector is exact in both.

`bpx_body_quoted` is the class `quotedBodyJs` puts on a run it has spliced into
a panel, or on a block it has emptied.  `bpx_body_folded` is the class the
control puts on a panel to fold the spliced value away again.  Print undoes both
and shows the page the chapter wrote: signatures in the panels, quoted blocks
where they stand.
-/
def quotedBodyCss : String := r##"
/* A quoted run the script has spliced into a panel leaves the prose. */
code.hl.lean.block .bpx_body_quoted,
code.hl.lean.block.bpx_body_quoted {
  display: none;
}

/* Folding the value away again leaves the signature the panel always had. */
.declaration.bpx_body_folded .bpx_body_value {
  display: none;
}

/* On paper nothing folds and nothing hovers, so print the page the chapter
   wrote: signatures in the panels, quoted blocks where they stand. */
@media print {
  code.hl.lean.block .bpx_body_quoted {
    display: inline;
  }

  code.hl.lean.block.bpx_body_quoted {
    display: block;
  }

  .bpx_body_value,
  .bpx_body_chip {
    display: none;
  }
}

/* The control has to look like something to press.  It borrows the panel
   badge's shape and sits at the end of the kicker's `def · defined in <path>`
   line; the chevron turns when the value is folded away. */
.bpx_body_chip {
  display: inline-flex;
  align-items: center;
  gap: 0.22rem;
  padding: 0.04rem 0.4rem;
  border: 1px solid var(--bp-color-border-muted);
  border-radius: 0.75rem;
  background: var(--bp-color-surface);
  color: var(--bp-color-text-strong);
  font-family: inherit;
  font-size: 0.66rem;
  font-weight: 600;
  line-height: 1.35;
  cursor: pointer;
}

.bpx_body_chip::after {
  content: "\25b4";
  font-size: 0.62rem;
  line-height: 1;
}

.bpx_body_folded .bpx_body_chip::after {
  content: "\25be";
}

.bpx_body_chip:hover,
.bpx_body_chip:focus-visible {
  border-color: var(--bp-color-border-strong);
  background: var(--bp-color-surface-muted);
}

/* A touch device has no hover, so the control is tapped rather than pointed at,
   and 0.66rem of text is not a tap target.  Grow it there only, and pull the
   row back so the kicker keeps its height on a pointer device. */
@media (hover: none) {
  .bpx_body_chip {
    padding: 0.42rem 0.55rem;
    margin: -0.35rem -0.15rem;
  }
}

/* A cross-reference whose target sits in a hidden run has had its href removed;
   keep it looking like the token it is, not like a dead link. */
.bpx_body_value a:not([href]) {
  color: inherit;
  text-decoration: none;
  cursor: text;
}

/* The block still standing in the prose, and the preview's form of the same
   thing.  A block the script emptied is hidden outright, so what is styled here
   is only what a reader still sees: the supporting definitions that no panel
   claims. */
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

/--
Splices each quoted body into the panel that declares it.

The external-declaration panel renders a signature and cannot render a value
(`notes/upstream.md` §8), which is why a chapter that needs the value quotes it
in a Lean block beside the panel.  This joins the two rather than choosing
between them, because each carries what the other lacks.

The signature is generated from the pinned environment, so it has the full name,
the universe levels, the qualified types, and every binder a `variable` block
supplied -- `RB31E2E.Sparse22.{u_1} {V : Type u_1} [DecidableEq V] (F :
RB31E2E.SimpleEdgeSet V) : Prop`, where the quoted source says only `def
Sparse22 (F : SimpleEdgeSet V) : Prop`.  The quoted body has the value and
nothing else the signature does not already say better.  So the panel keeps its
signature and gains the value spliced onto the end of it, and the run the value
came from leaves the prose.  Nothing is shown twice and nothing is lost.

Finding where the value starts is the only hard part left.  Every block holds
exactly one extracted declaration -- `BodyPinBlueprint.Bodies` emits one block
per name -- so the block is the run, and what remains is to say where its header
stops.  Lean writes a value in three forms; `valueFrom` asks about `where`
before it looks for `:=`, and the comment there says why that order is the whole
point of the function.

Nothing here is a patch or a post-processing step.  Verso inlines it into every
page's `<head>` from `RenderConfig.extraJs`, and it reads only what Verso
already rendered -- `div.declaration[data-decl]` for the panels, and the `id`
Verso puts on a block's defining occurrence of a constant (`Token.Kind.idAttr`,
which emits one only for a definition site).  Extracted names are fully
qualified, so `RB31E2E___Sparse22` unslugs to the panel's own `data-decl` and
the join is exact rather than guessed.

What it declines to do matters as much.  A page with no panels is left alone,
which is every preview render.  A block whose declaration no panel claims stays
in the prose, and so does one whose value cannot be located: on the sparsity
page `Sparse22` and `Tight22` move into their panels while `SimpleEdge`,
`SimpleEdgeSet`, `vertices` and `edgesInside` stay, since no node names them.
When the panel holding a value is inside a closed `details`, the block returns
to the prose, so folding the Lean code panel never hides a body with no way to
ask for it.

Cross-references follow that.  A reference from one quoted body to another points
at the block in the prose, whose anchors are untouched; the link is switched off
only while that block is hidden, and comes back when it returns.  Which block the
reference *came* from is irrelevant, so the target is looked up across the
document rather than within one block -- with a declaration per block, a
reference almost always leaves the block it is written in.

The control is a bordered pill with a chevron rather than a word in the kicker
line, because an affordance nobody can see is one nobody uses.  It folds the
value away and back.  It is a real `<button>`, so it takes keyboard focus and
carries `aria-expanded`, and `quotedBodyCss` grows it under
`@media (hover: none)`, since 0.66rem of text is not a tap target.

**Where the `where` case is fixed, and why not in Lean.**  `PLAN.md` proposed
reparsing `code.toString` in `Bodies.lean`, where `declValSimple`, `declValEqns`
and `whereStructInst` name the three forms exactly.  That would work, but the
boundary would then have to be carried into the DOM, and Verso gives no way to
mark a run inside a rendered block -- which is the same wall that made splicing
necessary in the first place.  It turns out not to be needed: SubVerso already
records, on every keyword atom, the parser production it belongs to
(`Code.lean`, `occ := s!"{name}-{pos}"`), so the real parse arrives in the page
as `data-binding` and no reparse is required.

The catch, and the reason `:=` and `|` are still token searches: SubVerso emits
a `keyword` token only for an atom that starts with a letter, so `:=` and `|`
arrive as ordinary tokens carrying no binding at all.  No route -- Lean's or
this one -- would have given them a production to match on.  `where` is a
keyword and does carry one, and `where` is the case that was wrong.

Checked over the extracts rather than on a page.  Of the 118 `def`, `abbrev` and
`instance` commands in the fifteen extracted modules, the rule moves the
boundary on exactly the twelve written with `where`, in each case to the `where`
itself and away from a field's `:=`; the other 106 are unchanged.  When it was
written it changed nothing the chapters showed.  It does now: `connectingMap`
and `directionEquilibrium` are both quoted, both are `LinearMap`s written with
`where`, and both are spliced into a panel, so without this the deletion chapter
would render two bodies beginning at `toFun z :=` with the `where` and the field
name silently gone.

The same reading gives `hasValue`.  A `structure` writes `where` before its
fields and may give a field a default with `:=`, both of which read exactly like
a value, so a block quoting one would have had something plausible spliced into
a panel that already lists the fields.  Refusing anything that is not a
definition excludes 152 theorems, 30 `omit ... in` commands and 3 structures
across the same extracts.

No count of what this does belongs here, because it would have to be corrected
every time a chapter quotes something. The shape is fixed instead: one block per
name in a ```BodyPinBlueprint.bodies fence, and a block moves into a panel
exactly when some node also names its declaration. Which blocks those are is
readable off the fences and the `(lean := ...)` options without a build, and
`scripts/coverage.py` is what keeps the two lists in step.
-/
def quotedBodyJs : String := r##"
(function () {
  "use strict";

  /* Verso slugs a declaration's anchor id and `.` has no replacement entry, so
     it arrives as `___` (multi-verso, MultiVerso/Slug.lean). */
  function unslug(s) {
    return s.replace(/___/g, ".");
  }

  /* A quoted body is a Lean block in the prose.  A panel signature carries the
     same `hl lean block` classes on a `pre` rather than a `code`; excluding the
     panels by position as well costs nothing and does not depend on that. */
  function quotedBlocks() {
    var all = document.querySelectorAll("code.hl.lean.block");
    var out = [];
    for (var i = 0; i < all.length; i++) {
      if (!all[i].closest(".declaration, .bp_external_decl_item, .bp_preview_panel")) {
        out.push(all[i]);
      }
    }
    return out;
  }

  /* A block holds one extracted declaration, and the token that defines it
     carries the slug of its full name.  `Token.Kind.idAttr` emits an id only at
     a definition site, and `Bodies.lean` asks for those with `defSite := true`,
     so the first such token is the declaration the block is. */
  function definedBy(block) {
    return block.querySelector(".const.token[id]");
  }

  /* SubVerso records, on every alphabetic keyword token, the parser production
     it belongs to and where that production started:
     `kw-occ-Lean.Parser.Command.whereStructInst-3348`.  That is the real syntax
     tree rather than a guess about the text, and it is what the two functions
     below read. */
  var KW = "kw-occ-Lean.Parser.Command.";

  function production(node) {
    var b = node.getAttribute && node.getAttribute("data-binding");
    if (!b || b.indexOf(KW) !== 0) return null;
    return b.slice(KW.length).replace(/-\d+$/, "");
  }

  /* Only a definition has a value worth splicing.  A structure or an inductive
     already has its fields and constructors rendered in the panel, and would be
     misread here: `structure ... where` and a field default `x : T := d` both
     look exactly like a value.  A theorem's value is a proof, which the
     blueprint does not reproduce. */
  var HAS_VALUE = { definition: 1, abbrev: 1, instance: 1 };

  function hasValue(nodes) {
    for (var i = 0; i < nodes.length; i++) {
      var p = production(nodes[i]);
      if (p && HAS_VALUE[p]) return true;
    }
    return false;
  }

  function childrenOf(block) {
    var out = [];
    for (var i = 0; i < block.childNodes.length; i++) out.push(block.childNodes[i]);
    return out;
  }

  /* Where the declaration stops restating its signature and starts saying what
     it is.  Lean writes a value in three forms, and the parser names all three:
     `whereStructInst` (`where`, then fields), `declValSimple` (`:=`, then a
     term) and `declValEqns` (pattern-matching alternatives).

     `where` is asked about first, and that ordering is the whole reason this
     function is not simply a search for `:=`.  A `where` declaration has no
     header-closing `:=` at all, so its first `:=` belongs to a *field*: looking
     for `:=` first would start the value at `toFun weight v j :=` and silently
     drop the `where` and the field name, which still looks plausible on the
     page.  `RB31E2E.DirectionStress.directionEquilibrium` is that declaration.

     Only `where` can be read off the syntax tree, because SubVerso records a
     production for alphabetic keywords and `:=` and `|` are not keywords in
     that sense -- they arrive as ordinary tokens with no binding at all.  So
     the other two forms are still found by their token, the `:=` at bracket
     depth zero so that a binder's default cannot be mistaken for it, and the
     `|` of a declaration such as `pinCapacity` taken with the line break in
     front of it. */
  function valueFrom(block, nodes) {
    var i, c;
    for (i = 0; i < nodes.length; i++) {
      if (production(nodes[i]) === "whereStructInst") return nodes.slice(i);
    }
    /* A `where` below the top level of the block would leave the search that
       follows to start the value inside a field.  Nothing renders that way
       today; refuse rather than find out on the page. */
    if (block.querySelector("[data-binding^='" + KW + "whereStructInst-']")) return null;
    var depth = 0;
    for (i = 0; i < nodes.length; i++) {
      var text = nodes[i].textContent;
      if (depth === 0 && text === ":=") return nodes.slice(i);
      for (c = 0; c < text.length; c++) {
        var ch = text.charAt(c);
        if (ch === "(" || ch === "[" || ch === "{") depth += 1;
        else if (ch === ")" || ch === "]" || ch === "}") depth -= 1;
      }
    }
    for (i = 0; i < nodes.length; i++) {
      if (nodes[i].textContent !== "|") continue;
      var j = i;
      while (j > 0 && !nodes[j - 1].textContent.trim()) j -= 1;
      return nodes.slice(j);
    }
    return null;
  }

  /* Ids are rewritten rather than dropped, so the tactic-state toggles inside a
     quoted proof keep working and nothing collides with the copy still in the
     page.  A cross-reference to another definition of the same block still
     points at that copy, whose anchors are untouched: the link is remembered
     here and switched off by `syncLinks` only while its target is hidden, so
     `Sparse22` can still jump to the `edgesInside` the prose kept. */
  var serial = 0;

  function isolate(root) {
    var mapped = {};
    var suffix = "--body-" + ++serial;
    var i;
    var withId = root.querySelectorAll("[id]");
    for (i = 0; i < withId.length; i++) {
      mapped[withId[i].id] = withId[i].id + suffix;
      withId[i].id = withId[i].id + suffix;
    }
    var labels = root.querySelectorAll("[for]");
    for (i = 0; i < labels.length; i++) {
      var target = labels[i].getAttribute("for");
      if (mapped[target]) labels[i].setAttribute("for", mapped[target]);
    }
    var links = root.querySelectorAll("a[href]");
    for (i = 0; i < links.length; i++) {
      var href = links[i].getAttribute("href");
      var hash = href.indexOf("#");
      if (hash === -1) continue;
      var frag = decodeURIComponent(href.slice(hash + 1));
      var anchor = targetIn(document, frag);
      if (anchor && anchor.closest("code.hl.lean.block")) {
        links[i].setAttribute("data-bpx-target", frag);
      }
    }
    return root;
  }

  function targetIn(root, id) {
    var escaped = window.CSS && CSS.escape ? CSS.escape(id) : id;
    try {
      return root.querySelector("[id=" + JSON.stringify(escaped) + "]");
    } catch (e) {
      return null;
    }
  }

  /* A link into a run that is currently hidden would go nowhere, so it stops
     being a link until the run comes back. */
  function syncLinks() {
    var links = document.querySelectorAll("[data-bpx-target]");
    for (var i = 0; i < links.length; i++) {
      var target = targetIn(document, links[i].getAttribute("data-bpx-target"));
      var live = target && !target.closest(".bpx_body_quoted");
      if (live) {
        if (!links[i].hasAttribute("href")) {
          links[i].setAttribute("href", links[i].getAttribute("data-bpx-href"));
        }
      } else if (links[i].hasAttribute("href")) {
        links[i].setAttribute("data-bpx-href", links[i].getAttribute("href"));
        links[i].removeAttribute("href");
      }
    }
  }

  /* Append the value to one rendering of the signature.  The panel carries two,
     for wide and narrow viewports, and both need it.

     The trailing newline the extract ends with is dropped by removing the
     whitespace-only children that carry it.  Trimming the last child's
     `textContent` instead is what this used to do, and it was destructive:
     assigning `textContent` to an *element* replaces its whole subtree with one
     flat text node.  Every quoted body ends in an element, so every spliced
     value lost the markup of its final token, and where that token was a `by`
     block the flattening fused the tactic label with the hidden goal state --
     `rigidityOperator` rendered `... else 0All goals completed! 🐙` in its
     panel.  So the trim now runs only on a text node, where it means what it
     says. */
  function splice(pre, value) {
    var span = document.createElement("span");
    span.className = "bpx_body_value";
    if (value[0].textContent.trim()) span.appendChild(document.createTextNode(" "));
    for (var i = 0; i < value.length; i++) span.appendChild(value[i].cloneNode(true));
    while (span.lastChild && !span.lastChild.textContent.trim()) {
      span.removeChild(span.lastChild);
    }
    if (span.lastChild && span.lastChild.nodeType === 3) {
      span.lastChild.nodeValue = span.lastChild.nodeValue.replace(/\s+$/, "");
    }
    pre.appendChild(isolate(span));
    return span;
  }

  /* The control folds the value away again.  It says what it does rather than
     sitting there invisibly: a bordered pill in the kicker, with a chevron that
     turns. */
  function addChip(panel, shortName, onToggle) {
    var row = panel.querySelector(".bp_external_decl_kicker_main");
    if (!row) return null;
    var chip = document.createElement("button");
    chip.type = "button";
    chip.className = "bpx_body_chip";
    chip.setAttribute("aria-expanded", "true");
    chip.setAttribute("aria-label", "Hide the quoted body of " + shortName);
    chip.appendChild(document.createTextNode("body"));
    chip.addEventListener("click", function () {
      var folded = panel.classList.toggle("bpx_body_folded");
      chip.setAttribute("aria-expanded", folded ? "false" : "true");
      chip.setAttribute(
        "aria-label",
        (folded ? "Show the quoted body of " : "Hide the quoted body of ") + shortName
      );
      if (onToggle) onToggle(folded);
    });
    row.appendChild(chip);
    return chip;
  }

  /* A panel lives inside a `details` the reader can close.  A block whose panel
     is out of reach comes back to the prose, so closing the Lean code panel
     never hides a body with no way to ask for it. */
  function reachable(node) {
    var d = node.closest("details");
    while (d) {
      if (!d.open) return false;
      d = d.parentElement && d.parentElement.closest("details");
    }
    return true;
  }

  function sync(hidden) {
    for (var i = 0; i < hidden.length; i++) {
      hidden[i].el.classList.toggle("bpx_body_quoted", reachable(hidden[i].panel));
    }
  }

  function run() {
    var panels = document.querySelectorAll("div.declaration[data-decl]");
    if (!panels.length) return;
    var byName = {};
    for (var i = 0; i < panels.length; i++) {
      var d = panels[i].getAttribute("data-decl");
      if (!(d in byName)) byName[d] = panels[i];
    }

    var blocks = quotedBlocks();
    var hidden = [];
    for (var b = 0; b < blocks.length; b++) {
      var block = blocks[b];
      var defines = definedBy(block);
      if (!defines) continue;
      var name = unslug(defines.id);
      var panel = byName[name];
      if (!panel) continue;
      var nodes = childrenOf(block);
      if (!hasValue(nodes)) continue;
      var value = valueFrom(block, nodes);
      if (!value) continue;
      var sigs = panel.querySelectorAll("pre.bp_external_decl_signature");
      if (!sigs.length) continue;
      for (var s = 0; s < sigs.length; s++) splice(sigs[s], value);
      addChip(panel, name.split(".").pop());
      hidden.push({ el: block, panel: panel });
    }

    if (!hidden.length) return;
    var refresh = function () { sync(hidden); syncLinks(); };
    refresh();
    /* `toggle` does not bubble, so listen in the capture phase. */
    document.addEventListener("toggle", refresh, true);
  }

  if (document.readyState === "complete") run();
  else window.addEventListener("load", run);
})();
"##

end BodyPinBlueprint

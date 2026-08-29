/-
Project CSS and JavaScript, passed to the generator as `RenderConfig.extraCss`
and `RenderConfig.extraJs`.

Verso's `HtmlAssets` describes both as "extra CSS/JS to be included inline into
every `<head>`" via `<style>` and `<script>` tags; the config's copies are
merged into the traverse state when it is initialised, so a project can style
and script its own pages without patching VersoBlueprint or post-processing the
output.  Both entry points pass both, so the site and `scripts/preview.py`
agree.

The two builds render a quoted body differently.  The site elaborates the fence
and emits `<code class="hl lean block">`; the preview strips the fence, because
it has no formalization to resolve names against, and emits an unclassed
`<pre>`.  The block rule names both, so the preview is a fair picture of where a
block sits and how heavy it looks.  A preview render has no declaration panels
either, so `quotedBodyJs` does nothing there and the fast loop is unaffected.

They differ in one visible way, and it is the site that shows less.  Verso's
highlighter drops comments -- there is not one `.comment` span anywhere on the
built site -- so the `-- <path>` first line of every quoted body is invisible
there, while the preview keeps it as ordinary text.  That line is a marker for
`scripts/check-snippets.py`, not something the reader ever sees on the site; a
reader who wants the file follows the source link on the declaration panel.  A
caption rule styling that first line was written here and removed once the built
page showed it matches nothing.

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

Finding where the value starts is the whole trick.  Verso renders a block as one
flat run of top-level nodes and marks every command start with a
`kw-occ-Lean.Parser.Command.<kind>` binding on its keyword token, which cuts a
cluster into one run per declaration: `namespace` and `end` are scaffolding, and
a modifier like `noncomputable` joins what it modifies.  Within a run the value
begins at the `:=` that closes the header, found at bracket depth zero so a
binder's default cannot be mistaken for it -- or, for a declaration given by
pattern-matching alternatives such as `pinCapacity`, at the first `|`.

Nothing here is a patch or a post-processing step.  Verso inlines it into every
page's `<head>` from `RenderConfig.extraJs`, and it reads only what Verso
already rendered -- `div.declaration[data-decl]` for the panels, and the `id`
Verso puts on a block's defining occurrence of a constant (`Token.Kind.idAttr`,
which emits one only for a definition site).

What it declines to do matters as much.  A page with no panels is left alone,
which is every preview render.  A short name is resolved to a panel's full name
by unique dotted suffix, and an ambiguous or unmatched one is skipped rather
than guessed.  A run whose value it cannot locate stays in the prose.  A block
keeps whatever it still holds: on the sparsity page `Sparse22` and `Tight22`
move into their panels while `SimpleEdge`, `SimpleEdgeSet`, `vertices` and
`edgesInside` stay, since no node claims them -- and a block with nothing left
but scaffolding is hidden whole.  When every panel holding a run is inside a
closed `details`, the run returns to the prose, so folding the Lean code panel
never hides a body with no way to ask for it.

Cross-references follow that.  A reference from one quoted body to another
points at the copy in the prose, whose anchors are untouched; the link is
switched off only while its target is hidden, and comes back when it returns.

The control is a bordered pill with a chevron rather than a word in the kicker
line, because an affordance nobody can see is one nobody uses.  It folds the
value away and back.  It is a real `<button>`, so it takes keyboard focus and
carries `aria-expanded`, and `quotedBodyCss` grows it under
`@media (hover: none)`, since 0.66rem of text is not a tap target.

Two kinds of block feed this, and they are not equivalent.  A block written by
`BodyPinBlueprint.Bodies` holds one extracted declaration and names it in full,
so the id it carries is `RB31E2E___Sparse22` and the join is exact.  A block
still quoted by hand in a chapter holds a cluster and declares short names, so
it needs the segmentation and the dotted-suffix guess above.  One chapter --
Sparsity -- has been converted; eight blocks have not, which is why both paths
are here.  When the last one is converted, `slices`, `resolve` and the bracket
counting in `valueFrom` all become dead code.

**A latent defect, recorded so it is not rediscovered.** `valueFrom` looks for
the `:=` that closes a declaration's header, and a declaration written with
`where` has none -- its first `:=` at depth zero belongs to a *field*, so the
value would begin at `toFun weight v j :=` and the rendering would drop the
`where` and the field name while still looking plausible.  Nothing on the page
hits this: none of the nine quoted declarations uses `where`.  Twelve of the
declarations in the extracted modules do, so it will matter as soon as coverage
widens.  The fix is not to add `where` here but to take the boundary from the
syntax tree in Lean, where `Lean.Parser.Command.declValSimple`, `declValEqns`
and `whereStructInst` name the three forms exactly; every one of the 119
definitions in the extracted modules reparses, so that is available.  See
`PLAN.md`.

As of the pinned formalization this splices twelve values into seven panels,
hides seven blocks whole and four runs within others, and leaves seven blocks
standing in the prose.
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

  /* Snippets elaborate in the blueprint's own environment with the upstream
     namespace opened, so a block defines `genericRigidityRank` where the panel
     names `RB31E2E.BarJoint.genericRigidityRank`.  Match on a dotted suffix and
     accept only a unique hit, so an ambiguity is skipped rather than guessed. */
  function resolve(names, short) {
    var hit = null;
    for (var i = 0; i < names.length; i++) {
      if (names[i] === short || names[i].endsWith("." + short)) {
        if (hit) return null;
        hit = names[i];
      }
    }
    return hit;
  }

  /* Verso renders a block as one flat run of top-level nodes and marks the
     start of every command with a `kw-occ-Lean.Parser.Command.<kind>` binding
     on its keyword token, which is enough to cut a cluster into one run per
     declaration.  `namespace` and `end` are scaffolding and belong to no
     declaration; a modifier such as `noncomputable` introduces none of its own,
     so it joins the command it modifies.  A run carries its own trailing blank
     line, because that separator sits before the next command's keyword. */
  var SCAFFOLD = {
    namespace: 1, end: 1, section: 1, open: 1, variable: 1, universe: 1
  };
  var COMMAND = "kw-occ-Lean.Parser.Command.";

  function commandKind(node) {
    var binding = node.getAttribute && node.getAttribute("data-binding");
    if (!binding || binding.indexOf(COMMAND) !== 0) return null;
    return binding.slice(COMMAND.length).replace(/-\d+$/, "");
  }

  function definitionIn(node) {
    if (node.classList && node.classList.contains("const") && node.id) return node;
    if (!node.querySelector) return null;
    return node.querySelector(".const.token[id]");
  }

  function slices(block) {
    var segments = [];
    var current = null;
    var children = block.childNodes;
    for (var i = 0; i < children.length; i++) {
      var kind = commandKind(children[i]);
      if (kind) {
        current = { kind: kind, nodes: [], defines: null };
        segments.push(current);
      }
      if (!current) continue;
      current.nodes.push(children[i]);
      current.defines = current.defines || definitionIn(children[i]);
    }

    var out = [];
    var pending = [];
    for (var j = 0; j < segments.length; j++) {
      var seg = segments[j];
      if (SCAFFOLD[seg.kind]) { pending = []; continue; }
      if (!seg.defines) { pending = pending.concat(seg.nodes); continue; }
      out.push({ nodes: pending.concat(seg.nodes), defines: seg.defines });
      pending = [];
    }
    return out;
  }

  /* Where the declaration stops restating its signature and starts saying what
     it is.  Almost always the `:=` that closes the header, which has to be
     found at bracket depth zero so that a binder's default value cannot be
     mistaken for it; `pinCapacity` has no `:=` at all and gives its value as
     pattern-matching alternatives, so the first `|` serves instead, taken with
     the line break in front of it. */
  function valueFrom(nodes) {
    var depth = 0;
    var i, c, text;
    for (i = 0; i < nodes.length; i++) {
      text = nodes[i].textContent;
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

  function isolate(root, block) {
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
      if (targetIn(block, frag)) {
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
     for wide and narrow viewports, and both need it. */
  function splice(pre, value, block) {
    var span = document.createElement("span");
    span.className = "bpx_body_value";
    if (value[0].textContent === ":=") span.appendChild(document.createTextNode(" "));
    for (var i = 0; i < value.length; i++) span.appendChild(value[i].cloneNode(true));
    while (span.lastChild && !span.lastChild.textContent.trim()) {
      span.removeChild(span.lastChild);
    }
    if (span.lastChild) {
      span.lastChild.textContent = span.lastChild.textContent.replace(/\s+$/, "");
    }
    pre.appendChild(isolate(span, block));
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

  /* A panel lives inside a `details` the reader can close.  Anything whose
     every panel is out of reach comes back to the prose, so closing the Lean
     code panel never hides a body with no way to ask for it. */
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
      var any = false;
      for (var j = 0; j < hidden[i].panels.length; j++) {
        if (reachable(hidden[i].panels[j])) { any = true; break; }
      }
      hidden[i].el.classList.toggle("bpx_body_quoted", any);
    }
  }

  /* Take a run out of the prose without disturbing what is left: wrap it, so
     the separator it carries goes with it and nothing reflows. */
  function wrapRun(nodes) {
    var span = document.createElement("span");
    nodes[0].parentNode.insertBefore(span, nodes[0]);
    for (var i = 0; i < nodes.length; i++) span.appendChild(nodes[i]);
    return span;
  }

  function run() {
    var panels = document.querySelectorAll("div.declaration[data-decl]");
    if (!panels.length) return;
    var byName = {};
    var names = [];
    for (var i = 0; i < panels.length; i++) {
      var d = panels[i].getAttribute("data-decl");
      if (!(d in byName)) { byName[d] = panels[i]; names.push(d); }
    }

    var blocks = quotedBlocks();
    var hidden = [];
    for (var b = 0; b < blocks.length; b++) {
      var block = blocks[b];
      var runs = slices(block);
      var spliced = [];
      var left = 0;

      for (var r = 0; r < runs.length; r++) {
        var short = unslug(runs[r].defines.id);
        var full = resolve(names, short);
        var value = full ? valueFrom(runs[r].nodes) : null;
        if (!full || !value) { left += 1; continue; }

        var panel = byName[full];
        var sigs = panel.querySelectorAll("pre.bp_external_decl_signature");
        if (!sigs.length) { left += 1; continue; }
        for (var s = 0; s < sigs.length; s++) splice(sigs[s], value, block);
        addChip(panel, short);
        spliced.push({ nodes: runs[r].nodes, panel: panel });
      }

      if (!spliced.length) continue;

      if (left === 0) {
        /* Nothing definitional is left, so the scaffolding would be all that
           remained.  Hide the block whole. */
        hidden.push({ el: block, panels: spliced.map(function (x) { return x.panel; }) });
      } else {
        for (var k = 0; k < spliced.length; k++) {
          hidden.push({ el: wrapRun(spliced[k].nodes), panels: [spliced[k].panel] });
        }
      }
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

#!/usr/bin/env bash
#
# Everything that can be checked without building the document.
#
# About fifteen seconds, against ten minutes for scripts/ci-pages.sh, which
# runs this first through the pre-build hook. Run it before committing.
#
# The harness LT (source-fidelity) scripts are deliberately absent: there is no
# LaTeX source for this paper, so they cannot apply. See AGENTS.md.

set -euo pipefail

step() { printf '\n[checks] %s\n' "$*" >&2; }

chapters=(BodyPinBlueprint/Chapters/*.lean)

step "harness layout"
python3 tools/verso-harness/scripts/check_harness.py --project-root .

step "blueprint node kinds"
python3 tools/verso-harness/scripts/check_blueprint_node_kinds.py --project-root . "${chapters[@]}"

step "Verso math delimiters"
python3 tools/verso-harness/scripts/check_verso_math_delimiters.py --project-root . \
  BodyPinBlueprint.lean "${chapters[@]}"

step "heading structure"
python3 tools/verso-harness/scripts/check_blueprint_heading_structure.py --project-root . "${chapters[@]}"

step "quoted Lean snippets against the pinned submodule"
python3 scripts/check-snippets.py

step "coverage and correspondence"
python3 scripts/coverage.py --summary

step "witness prose against the paper (advisory, needs source/paper.txt)"
python3 scripts/check-witness-prose.py

step "prose register (advisory)"
python3 scripts/style-check.py

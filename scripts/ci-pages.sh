#!/usr/bin/env bash

set -euo pipefail

step() {
  printf '\n[ci-pages] %s\n' "$*" >&2
}

if [ -x scripts/ci-pre-build.sh ]; then
  step "running pre-build hook"
  scripts/ci-pre-build.sh
fi

step "warming dependency cache"
python3 tools/verso-harness/scripts/ensure_dependency_cache.py --project-root . --warm-cache

step "building Blueprint site"
# The generator does not clean its output directory, so a renamed section
# leaves its old page and search-index shard behind, and nothing links to
# either -- check-rendered.py cannot see an orphan. Remove the rendered site
# before rebuilding; _out/site keeps nothing else worth preserving.
rm -rf _out/site/html-multi
lake exe vbp build --output _out/site 2>&1 | python3 scripts/filter_docstring_warnings.py --project-root .

step "checking dependency cache after build"
python3 tools/verso-harness/scripts/ensure_dependency_cache.py --project-root .

step "checking generated site"
python3 tools/verso-harness/scripts/check_generated_site.py --project-root . --site-dir _out/site/html-multi

step "stamping the output with the source state it was built from"
python3 scripts/check-fresh.py --write _out/site/html-multi

# After the stamp, so the check can refuse to read a site that is not current.
# This is the only place the claims that are true of a *page* rather than of a
# chapter get checked; both of the bugs it looks for shipped green through
# checks.sh and were found by eye.
step "checking the rendered page"
python3 scripts/check-rendered.py

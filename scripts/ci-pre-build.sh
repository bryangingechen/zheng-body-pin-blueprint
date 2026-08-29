#!/usr/bin/env bash
#
# Hook run by scripts/ci-pages.sh before the ten-minute build. Anything that can
# fail without elaborating the document should fail here instead.

set -euo pipefail

here="$(dirname "$0")"

# The document reads declaration bodies out of `.lake/build/highlighted/`, so
# the extraction has to have run before any chapter elaborates. Lake traces the
# output on each module's olean, so this is seconds once warm and only pays its
# ~21 minutes when the submodule pin moves.
"$here/extract-bodies.sh"

exec "$here/checks.sh"

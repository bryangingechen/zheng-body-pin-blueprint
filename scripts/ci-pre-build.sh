#!/usr/bin/env bash
#
# Hook run by scripts/ci-pages.sh before the ten-minute build. Anything that can
# fail without elaborating the document should fail here instead.

set -euo pipefail
exec "$(dirname "$0")/checks.sh"

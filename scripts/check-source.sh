#!/usr/bin/env bash
# Verify the local copy of the paper and (re)generate its text layer.
# The paper is not committed; see source/README.md.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pdf="$root/source/paper.pdf"
txt="$root/source/paper.txt"

expected="$(python3 - "$root/correspondence.toml" <<'PY'
import sys, tomllib
print(tomllib.load(open(sys.argv[1], 'rb'))['paper']['sha256'])
PY
)"

if [ ! -f "$pdf" ]; then
  echo "missing: source/paper.pdf" >&2
  echo "See source/README.md for how to obtain it (DOI 10.13140/RG.2.2.17830.28485)." >&2
  exit 1
fi

actual="$(shasum -a 256 "$pdf" | cut -d' ' -f1)"

if [ "$actual" != "$expected" ]; then
  echo "source/paper.pdf does not match the version correspondence.toml maps." >&2
  echo "  expected $expected" >&2
  echo "  actual   $actual" >&2
  echo "Result numbering shifts between revisions; re-check correspondence.toml" >&2
  echo "entries before citing them." >&2
  exit 1
fi

echo "[source] paper.pdf matches correspondence.toml ($expected)"

if ! command -v pdftotext >/dev/null 2>&1; then
  echo "[source] pdftotext not found; skipping text layer (install poppler)." >&2
  exit 0
fi

pdftotext -layout "$pdf" "$txt"
echo "[source] regenerated paper.txt ($(wc -l < "$txt" | tr -d ' ') lines)"

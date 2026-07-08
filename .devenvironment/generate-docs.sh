#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v doxygen >/dev/null 2>&1; then
  echo "Doxygen not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

mkdir -p docs/doxygen
doxygen Doxyfile

index="$ROOT/docs/doxygen/html/index.html"
if [[ -f "$index" ]]; then
  echo "Generated Doxygen HTML:"
  echo "  file://$index"
else
  echo "Doxygen ran, but HTML index was not found." >&2
  exit 1
fi


#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

if ! command -v gcovr >/dev/null 2>&1; then
  echo "gcovr not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

rm -rf coverage
mkdir -p coverage

pio test -e native_coverage

gcovr \
  --root "$ROOT" \
  --object-directory "$ROOT/.pio/build/native_coverage" \
  --filter "$ROOT/src" \
  --filter "$ROOT/lib" \
  --exclude "$ROOT/test" \
  --exclude "$ROOT/.pio" \
  --print-summary \
  --html-details coverage/index.html \
  --xml-pretty \
  --xml coverage/coverage.xml \
  --txt coverage/coverage.txt

echo "Coverage HTML: file://$ROOT/coverage/index.html"


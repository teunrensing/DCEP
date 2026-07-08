#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
out_dir="reports/dependencies/$timestamp"
mkdir -p "$out_dir"

pio pkg list > "$out_dir/packages.txt" 2>&1 || true
pio pkg outdated > "$out_dir/outdated.txt" 2>&1 || true

if [[ -f platformio.ini ]]; then
  cp platformio.ini "$out_dir/platformio.ini"
fi

echo "Dependency snapshot written to $out_dir"


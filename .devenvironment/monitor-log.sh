#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p logs
log_file="logs/serial-$timestamp.log"

args=(device monitor)

if [[ -n "${PORT:-}" ]]; then
  args+=(--port "$PORT")
fi

if [[ -n "${BAUD:-}" ]]; then
  args+=(--baud "$BAUD")
fi

echo "Writing serial log to $log_file"
pio "${args[@]}" | tee "$log_file"


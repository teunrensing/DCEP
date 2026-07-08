#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

pio run -t compiledb "$@"

if [[ ! -f compile_commands.json ]]; then
  db="$(find .pio/build -name compile_commands.json -type f 2>/dev/null | head -n 1 || true)"
  if [[ -n "$db" ]]; then
    cp "$db" compile_commands.json
  fi
fi

if [[ -f compile_commands.json ]]; then
  echo "Generated $ROOT/compile_commands.json"
else
  echo "compile_commands.json was not produced. Check your PlatformIO environment." >&2
  exit 1
fi


#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  ROOT="$(git rev-parse --show-toplevel)"
fi

cd "$ROOT"

sudo chown -R "$(id -u):$(id -g)" /home/vscode/.platformio /home/vscode/.cache/ccache 2>/dev/null || true
find .devenvironment .reviewbot -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true

if [[ -f platformio.ini ]]; then
  pio pkg install || true
  .devenvironment/generate-compile-db.sh || true
fi

if [[ "${DEVENV_TEAM_MODE:-0}" == "1" ]]; then
  .devenvironment/apply-team-mode.sh
else
  echo "DEVENV_TEAM_MODE=0: solo mode enabled."
fi

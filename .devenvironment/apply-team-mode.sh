#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${DEVENV_TEAM_MODE:-0}" != "1" ]]; then
  echo "Team mode is disabled. Set DEVENV_TEAM_MODE=1 in .devcontainer/devcontainer.json and rebuild the dev container."
  exit 0
fi

copy_if_missing() {
  local src="$1"
  local dst="$2"

  if [[ -e "$dst" ]]; then
    echo "Keeping existing $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "Added $dst"
}

copy_if_missing ".devenvironment/team/CONTRIBUTING.md" "CONTRIBUTING.md"
copy_if_missing ".devenvironment/team/.pre-commit-config.yaml" ".pre-commit-config.yaml"
copy_if_missing ".devenvironment/team/platformio-ci.yml" ".github/workflows/platformio-ci.yml"
copy_if_missing ".devenvironment/team/pull_request_template.md" ".github/pull_request_template.md"
copy_if_missing ".devenvironment/team/bug_report.md" ".github/ISSUE_TEMPLATE/bug_report.md"
copy_if_missing ".devenvironment/team/feature_request.md" ".github/ISSUE_TEMPLATE/feature_request.md"
copy_if_missing ".devenvironment/team/0001-record-architecture-decisions.md" "docs/adr/0001-record-architecture-decisions.md"

if command -v pre-commit >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  pre-commit install --hook-type pre-commit || true
  pre-commit install --hook-type commit-msg || true
  pre-commit install --hook-type pre-push || true
fi

echo "Team mode files are ready."

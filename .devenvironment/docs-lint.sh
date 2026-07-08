#!/usr/bin/env bash
set -euo pipefail

status=0

run_optional() {
  local tool="$1"
  shift

  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool not found; skipping."
    return 0
  fi

  echo
  echo "==> $tool $*"
  set +e
  "$tool" "$@"
  code=$?
  set -e

  if [[ "$code" -ne 0 ]]; then
    status="$code"
  fi
}

run_optional codespell README.md docs .devenvironment .reviewbot
run_optional markdownlint-cli2 "README.md" "docs/**/*.md" ".devenvironment/team/*.md"

exit "$status"


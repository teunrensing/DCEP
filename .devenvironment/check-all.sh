#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

status=0

run_step() {
  echo
  echo "==> $*"
  set +e
  "$@"
  code=$?
  set -e
  if [[ "$code" -ne 0 ]]; then
    status="$code"
  fi
}

run_step pio run
run_step pio check --fail-on-defect medium
run_step .devenvironment/run-clang-tidy.sh
run_step .devenvironment/generate-docs.sh

exit "$status"

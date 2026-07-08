#!/usr/bin/env bash
set -euo pipefail

if [[ "${SKIP_PIO_PRE_PUSH:-0}" == "1" ]]; then
  echo "Skipping PlatformIO pre-push checks."
  exit 0
fi

pio run
pio check --fail-on-defect medium


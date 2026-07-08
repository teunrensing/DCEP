#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f Makefile ]]; then
  echo "No Makefile found; skipping default checks."
  exit 0
fi

make build
make check

if pio project config 2>/dev/null | grep -q 'env:native'; then
  make test-native
else
  echo "No PlatformIO native environment found; skipping make test-native."
fi

if pio project config 2>/dev/null | grep -q 'env:native_coverage'; then
  make coverage
else
  echo "No PlatformIO native_coverage environment found; skipping make coverage."
fi

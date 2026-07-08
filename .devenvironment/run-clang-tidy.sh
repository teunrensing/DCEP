#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

find_runner() {
  for name in run-clang-tidy run-clang-tidy-20 run-clang-tidy-19 run-clang-tidy-18 run-clang-tidy-17 run-clang-tidy-16 run-clang-tidy-15; do
    if command -v "$name" >/dev/null 2>&1; then
      command -v "$name"
      return 0
    fi
  done
  return 1
}

find_clang_tidy() {
  for name in clang-tidy clang-tidy-20 clang-tidy-19 clang-tidy-18 clang-tidy-17 clang-tidy-16 clang-tidy-15; do
    if command -v "$name" >/dev/null 2>&1; then
      command -v "$name"
      return 0
    fi
  done
  return 1
}

if [[ ! -f compile_commands.json ]]; then
  if [[ -n "${ENV:-}" ]]; then
    .devenvironment/generate-compile-db.sh -e "$ENV"
  else
    .devenvironment/generate-compile-db.sh
  fi
fi

runner="$(find_runner || true)"
if [[ -n "$runner" ]]; then
  args=(-p "$ROOT")
  if [[ "${FIX:-0}" == "1" ]]; then
    args+=(-fix -format)
  fi
  "$runner" "${args[@]}" "$@"
  exit $?
fi

clang_tidy="$(find_clang_tidy || true)"
if [[ -z "$clang_tidy" ]]; then
  echo "clang-tidy not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

mapfile -t files < <(
  find src lib test -type f \( \
    -name '*.c' -o \
    -name '*.cc' -o \
    -name '*.cpp' -o \
    -name '*.cxx' \
  \) 2>/dev/null | sort
)

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No source files found under src, lib, or test."
  exit 0
fi

fix_args=()
if [[ "${FIX:-0}" == "1" ]]; then
  fix_args+=(--fix --format-style=file)
fi

for file in "${files[@]}"; do
  "$clang_tidy" "$file" -p "$ROOT" --config-file="$ROOT/.clang-tidy" "${fix_args[@]}" "$@"
done

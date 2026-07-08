#!/usr/bin/env bash
set -euo pipefail

if ! command -v clang-format >/dev/null 2>&1; then
  echo "clang-format not found. Skipping formatting." >&2
  exit 0
fi

files=()
for file in "$@"; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.c|*.cc|*.cpp|*.cxx|*.h|*.hh|*.hpp|*.hxx|*.ino)
      files+=("$file")
      ;;
  esac
done

if [[ "${#files[@]}" -eq 0 ]]; then
  exit 0
fi

clang-format -i "${files[@]}"
git add "${files[@]}"


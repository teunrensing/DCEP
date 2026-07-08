#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Run .devenvironment/install-linux-tools.sh first." >&2
  exit 127
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
git_ref="$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"
out_dir="releases/${timestamp}-${git_ref}"
env_name="${ENV:-}"

if [[ -n "$env_name" ]]; then
  pio run -e "$env_name"
  envs=("$env_name")
else
  pio run
  mapfile -t envs < <(find .pio/build -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
fi

if [[ "${#envs[@]}" -eq 0 ]]; then
  echo "No PlatformIO build environments found under .pio/build." >&2
  exit 1
fi

mkdir -p "$out_dir"

cat > "$out_dir/manifest.txt" <<EOF
generated_at_utc=$timestamp
git_ref=$git_ref
env=${env_name:-all}
platformio=$(pio --version 2>/dev/null || echo unknown)
EOF

pio pkg list > "$out_dir/packages.txt" 2>&1 || true
pio pkg outdated > "$out_dir/outdated.txt" 2>&1 || true

shopt -s nullglob

for env in "${envs[@]}"; do
  build_dir=".pio/build/$env"
  target_dir="$out_dir/$env"

  if [[ ! -d "$build_dir" ]]; then
    echo "Skipping missing build directory: $build_dir"
    continue
  fi

  mkdir -p "$target_dir"

  for artifact in "$build_dir"/*.elf "$build_dir"/*.bin "$build_dir"/*.hex "$build_dir"/*.uf2 "$build_dir"/*.map; do
    cp "$artifact" "$target_dir/"
  done

  pio run -e "$env" -t size > "$target_dir/size.txt" 2>&1 || true
done

echo "Release artifacts written to $out_dir"

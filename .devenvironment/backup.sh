#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_dir="${BACKUP_DIR:-backups}"
project_name="$(basename "$ROOT")"
mkdir -p "$backup_dir"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git bundle create "$backup_dir/$project_name-$timestamp.bundle" --all
  git status --short > "$backup_dir/$project_name-$timestamp-status.txt"
fi

tar \
  --exclude='./.git' \
  --exclude='./.pio' \
  --exclude='./coverage' \
  --exclude='./logs' \
  --exclude='./reports' \
  --exclude='./releases' \
  --exclude='./backups' \
  -czf "$backup_dir/$project_name-$timestamp-worktree.tar.gz" .

echo "Backup written to $backup_dir"


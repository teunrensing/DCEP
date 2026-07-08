#!/usr/bin/env bash
set -euo pipefail

repo_name="${1:-}"
keep_days="${2:-${REVIEW_KEEP_DAYS:-30}}"
review_bot_home="${REVIEW_BOT_HOME:-/srv/review-bot}"

if [[ -z "$repo_name" || "$repo_name" == "-h" || "$repo_name" == "--help" ]]; then
  cat <<'MSG'
Usage:
  cleanup-review-bot.sh REPO_NAME [KEEP_DAYS]

Example:
  cleanup-review-bot.sh firmware 30
MSG
  exit 1
fi

if [[ ! "$keep_days" =~ ^[0-9]+$ ]]; then
  echo "KEEP_DAYS must be a number." >&2
  exit 1
fi

reports="$review_bot_home/reports/$repo_name"
worktrees="$review_bot_home/worktrees/$repo_name"

if [[ -d "$reports" ]]; then
  find "$reports" -type f \( -name '*.md' -o -name '*.diff' \) -mtime +"$keep_days" -delete
fi

if [[ -d "$worktrees" ]]; then
  find "$worktrees" -mindepth 1 -maxdepth 1 -type d -mtime +"$keep_days" -exec rm -rf {} +
fi

echo "Cleaned review-bot data older than $keep_days days for $repo_name."

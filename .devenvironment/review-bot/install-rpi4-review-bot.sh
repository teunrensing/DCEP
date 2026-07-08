#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'MSG'
Usage:
  .devenvironment/review-bot/install-rpi4-review-bot.sh REPO_NAME

Example:
  .devenvironment/review-bot/install-rpi4-review-bot.sh firmware

Environment:
  REVIEW_BOT_HOME=/srv/review-bot
MSG
}

repo_name="${1:-}"
if [[ -z "$repo_name" || "$repo_name" == "-h" || "$repo_name" == "--help" ]]; then
  usage
  exit 1
fi

if [[ ! "$repo_name" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid repo name. Use letters, numbers, dot, underscore, or hyphen." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required." >&2
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
review_bot_home="${REVIEW_BOT_HOME:-/srv/review-bot}"
repo_dir="$review_bot_home/repos/$repo_name.git"
runner_dir="$review_bot_home/bin"

mkdir -p "$review_bot_home/repos" "$review_bot_home/worktrees" "$review_bot_home/reports" "$runner_dir"

if [[ ! -d "$repo_dir" ]]; then
  git init --bare "$repo_dir"
fi

cp "$script_dir/run-review.sh" "$runner_dir/run-review.sh"
cp "$script_dir/cleanup-review-bot.sh" "$runner_dir/cleanup-review-bot.sh"
cp "$script_dir/post-receive" "$repo_dir/hooks/post-receive"
chmod +x "$runner_dir/run-review.sh" "$runner_dir/cleanup-review-bot.sh" "$repo_dir/hooks/post-receive"

cat > "$repo_dir/hooks/review-bot.conf" <<EOF
REVIEW_BOT_HOME="$review_bot_home"
REVIEW_RUNNER="$runner_dir/run-review.sh"
REVIEW_ASYNC=1
REVIEW_KEEP_DAYS=30
EOF

cat <<EOF
Review bot repo installed.

Bare repo:
  $repo_dir

Reports:
  $review_bot_home/reports/$repo_name

Cleanup old reports/worktrees:
  $runner_dir/cleanup-review-bot.sh $repo_name

Add this remote from your development machine:
  git remote add pi-review USER@PI_HOST:$repo_dir

Push for review:
  git push pi-review HEAD:refs/heads/review/my-change
EOF

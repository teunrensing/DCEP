#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:?repo_dir is required}"
old_rev="${2:?old_rev is required}"
new_rev="${3:?new_rev is required}"
ref_name="${4:?ref_name is required}"

review_bot_home="${REVIEW_BOT_HOME:-/srv/review-bot}"
repo_base="$(basename "$repo_dir")"
repo_name="${repo_base%.git}"
branch="${ref_name#refs/heads/}"
safe_branch="$(printf '%s' "$branch" | sed -E 's/[^A-Za-z0-9._-]+/-/g; s/^-+//; s/-+$//')"
safe_branch="${safe_branch:-unknown-ref}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"

zero_rev="0000000000000000000000000000000000000000"
report_dir="$review_bot_home/reports/$repo_name"
worktree_base="$review_bot_home/worktrees/$repo_name"
lock_dir="$review_bot_home/locks"

mkdir -p "$report_dir" "$worktree_base" "$lock_dir"

lock_file="$lock_dir/$repo_name.lock"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$lock_file"
  flock 9
fi

if [[ "$new_rev" == "$zero_rev" ]]; then
  report_file="$report_dir/$timestamp-$safe_branch-deleted.md"
  {
    echo "# Review skipped"
    echo
    echo "Ref deleted: \`$ref_name\`"
  } > "$report_file"
  ln -sfn "$(basename "$report_file")" "$report_dir/latest.md"
  exit 0
fi

short_rev="$(git --git-dir="$repo_dir" rev-parse --short "$new_rev")"
worktree="$worktree_base/$timestamp-$safe_branch-$short_rev"
report_file="$report_dir/$timestamp-$safe_branch-$short_rev.md"
diff_file="$report_dir/$timestamp-$safe_branch-$short_rev.diff"

if [[ "$old_rev" == "$zero_rev" ]]; then
  if base_rev="$(git --git-dir="$repo_dir" rev-parse "$new_rev^" 2>/dev/null)"; then
    diff_base="$base_rev"
  else
    diff_base="$new_rev"
  fi
else
  diff_base="$old_rev"
fi

git --git-dir="$repo_dir" diff --find-renames "$diff_base" "$new_rev" > "$diff_file" || true

{
  echo "# Local review"
  echo
  echo "- Repository: \`$repo_name\`"
  echo "- Ref: \`$ref_name\`"
  echo "- Old revision: \`$old_rev\`"
  echo "- New revision: \`$new_rev\`"
  echo "- Diff base: \`$diff_base\`"
  echo "- Generated UTC: \`$timestamp\`"
  echo
  echo "## Diff summary"
  echo
  echo '```text'
  git --git-dir="$repo_dir" diff --stat "$diff_base" "$new_rev" || true
  echo '```'
} > "$report_file"

cleanup() {
  git --git-dir="$repo_dir" worktree remove --force "$worktree" >/dev/null 2>&1 || rm -rf "$worktree"
}
trap cleanup EXIT

git --git-dir="$repo_dir" worktree add --detach "$worktree" "$new_rev" >/dev/null

export REVIEW_REPO_DIR="$repo_dir"
export REVIEW_WORKTREE="$worktree"
export REVIEW_OLD_REV="$old_rev"
export REVIEW_NEW_REV="$new_rev"
export REVIEW_REF_NAME="$ref_name"
export REVIEW_BRANCH="$branch"
export REVIEW_DIFF_FILE="$diff_file"
export REVIEW_REPORT_FILE="$report_file"

{
  echo
  echo "## Checks"
  echo
  echo '```text'
} >> "$report_file"

set +e
if [[ -f "$worktree/.reviewbot/checks.sh" ]]; then
  (
    cd "$worktree"
    bash .reviewbot/checks.sh
  ) >> "$report_file" 2>&1
  checks_status=$?
elif [[ -f "$worktree/Makefile" ]]; then
  (
    cd "$worktree"
    make build
    make check
  ) >> "$report_file" 2>&1
  checks_status=$?
else
  echo "No .reviewbot/checks.sh or Makefile found; checks skipped." >> "$report_file"
  checks_status=0
fi
set -e

{
  echo '```'
  echo
  echo "Checks exit code: \`$checks_status\`"
} >> "$report_file"

if [[ -f "$worktree/.reviewbot/review-command.sh" ]]; then
  set +e
  (
    cd "$worktree"
    bash .reviewbot/review-command.sh
  ) >> "$report_file" 2>&1
  review_status=$?
  set -e
  {
    echo
    echo "Review CLI exit code: \`$review_status\`"
  } >> "$report_file"
else
  {
    echo
    echo "## CLI Review"
    echo
    echo "No \`.reviewbot/review-command.sh\` configured."
  } >> "$report_file"
fi

ln -sfn "$(basename "$report_file")" "$report_dir/latest.md"

if [[ "$checks_status" -ne 0 ]]; then
  exit "$checks_status"
fi

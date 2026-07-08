#!/usr/bin/env bash
set -euo pipefail

: "${REVIEW_DIFF_FILE:?REVIEW_DIFF_FILE is required}"
: "${REVIEW_REPORT_FILE:?REVIEW_REPORT_FILE is required}"

cat >> "$REVIEW_REPORT_FILE" <<'MSG'

## CLI Review

No review CLI is configured yet.

To enable one, copy:

```bash
cp .reviewbot/review-command.example.sh .reviewbot/review-command.sh
```

Then edit `.reviewbot/review-command.sh` to call your CLI and append its output to `REVIEW_REPORT_FILE`.

MSG

# Example shape:
#
# your-review-cli \
#   --repo "$REVIEW_WORKTREE" \
#   --diff "$REVIEW_DIFF_FILE" \
#   >> "$REVIEW_REPORT_FILE"


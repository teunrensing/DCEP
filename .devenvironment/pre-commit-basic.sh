#!/usr/bin/env bash
set -euo pipefail

status=0
max_bytes=$((5 * 1024 * 1024))

for file in "$@"; do
  [[ -f "$file" ]] || continue

  if grep -nI -E '^(<<<<<<<|=======|>>>>>>>)' "$file" >/tmp/precommit-conflict.$$ 2>/dev/null; then
    echo "Merge conflict marker found in $file"
    cat /tmp/precommit-conflict.$$
    status=1
  fi

  if grep -nI -E 'BEGIN (RSA|DSA|EC|OPENSSH|PRIVATE) KEY' "$file" >/tmp/precommit-key.$$ 2>/dev/null; then
    echo "Possible private key found in $file"
    cat /tmp/precommit-key.$$
    status=1
  fi

  size="$(wc -c < "$file")"
  if [[ "$size" -gt "$max_bytes" ]]; then
    echo "Large file staged: $file (${size} bytes)."
    status=1
  fi
done

rm -f /tmp/precommit-conflict.$$ /tmp/precommit-key.$$
exit "$status"


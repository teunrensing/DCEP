#!/usr/bin/env bash
set -euo pipefail

msg_file="${1:?commit message file required}"
first_line="$(head -n 1 "$msg_file")"

case "$first_line" in
  Merge\ *|Revert\ *|fixup!\ *|squash!\ *)
    exit 0
    ;;
esac

pattern='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?: .{1,72}$'

if [[ "$first_line" =~ $pattern ]]; then
  exit 0
fi

cat >&2 <<'MSG'
Commit message should use conventional commits, for example:

  feat(sensor): add oversampling mode
  fix(serial): handle empty frames
  docs: document debug wiring
MSG

exit 1


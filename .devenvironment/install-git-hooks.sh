#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This is not a Git repository. Run git init first." >&2
  exit 1
fi

mkdir -p .git/hooks

cat > .git/hooks/pre-commit <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v clang-format >/dev/null 2>&1; then
  echo "clang-format not found; skipping format hook." >&2
  exit 0
fi

mapfile -t files < <(
  git diff --cached --name-only --diff-filter=ACMR |
    grep -E '\.(c|cc|cpp|cxx|h|hh|hpp|hxx|ino)$' || true
)

if [[ "${#files[@]}" -eq 0 ]]; then
  exit 0
fi

clang-format -i "${files[@]}"
git add "${files[@]}"
HOOK

cat > .git/hooks/pre-push <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${SKIP_PIO_PRE_PUSH:-0}" == "1" ]]; then
  echo "Skipping PlatformIO pre-push checks."
  exit 0
fi

pio run
pio check --fail-on-defect medium
HOOK

chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "Installed optional solo Git hooks: pre-commit and pre-push."


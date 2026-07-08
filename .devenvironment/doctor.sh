#!/usr/bin/env bash
set -euo pipefail

have() {
  command -v "$1" >/dev/null 2>&1
}

section() {
  echo
  echo "== $1"
}

version_line() {
  local name="$1"
  shift

  if have "$name"; then
    "$@" 2>&1 | head -n 1 || true
  else
    echo "$name: not found"
  fi
}

section "Tool versions"
version_line pio pio --version
version_line python3 python3 --version
version_line git git --version
version_line make make --version
version_line ccache ccache --version
version_line clang clang --version
version_line clangd clangd --version
version_line clang-tidy clang-tidy --version
version_line clang-format clang-format --version
version_line cppcheck cppcheck --version
version_line doxygen doxygen --version
version_line gcovr gcovr --version
version_line codespell codespell --version
version_line markdownlint-cli2 markdownlint-cli2 --version
version_line openocd openocd --version
version_line gdb-multiarch gdb-multiarch --version

section "PlatformIO project"
if [[ -f platformio.ini ]]; then
  pio project config || true
else
  echo "platformio.ini not found in the current directory."
fi

section "Compile database"
if [[ -f compile_commands.json ]]; then
  echo "compile_commands.json: present"
else
  echo "compile_commands.json: missing. Run make compiledb."
fi

section "ccache"
if have ccache; then
  ccache --show-stats || true
else
  echo "ccache: not found"
fi

section "Devices"
if have pio; then
  pio device list || true
fi

section "Linux permissions"
id || true
if id -nG 2>/dev/null | grep -qw dialout; then
  echo "dialout group: yes"
else
  echo "dialout group: no. Add your user with: sudo usermod -aG dialout \"$USER\""
fi

section "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short || true
  echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
else
  echo "Not inside a Git repository."
fi

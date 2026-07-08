#!/usr/bin/env bash
set -euo pipefail

have() {
  command -v "$1" >/dev/null 2>&1
}

install_platformio() {
  if have pio; then
    echo "PlatformIO already installed: $(pio --version)"
    return
  fi

  if have pipx; then
    pipx install platformio || pipx upgrade platformio
    pipx ensurepath || true
  else
    python3 -m pip install --user --upgrade platformio
    echo "Make sure ~/.local/bin is in PATH."
  fi
}

if have apt-get; then
  sudo apt-get update
  sudo apt-get install -y \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    clangd \
    cppcheck \
    doxygen \
    graphviz \
    gdb-multiarch \
    lcov \
    make \
    nodejs \
    npm \
    openocd \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    shellcheck \
    bear
elif have dnf; then
  sudo dnf install -y \
    clang \
    clang-tools-extra \
    clangd \
    ccache \
    cppcheck \
    doxygen \
    graphviz \
    gdb \
    lcov \
    make \
    nodejs \
    npm \
    openocd \
    python3 \
    python3-pip \
    pipx \
    bear
elif have pacman; then
  sudo pacman -Syu --needed \
    clang \
    ccache \
    cppcheck \
    doxygen \
    graphviz \
    gdb \
    lcov \
    make \
    nodejs \
    npm \
    openocd \
    python \
    python-pip \
    python-pipx \
    bear
elif have zypper; then
  sudo zypper install -y \
    clang \
    clang-tools \
    clangd \
    ccache \
    cppcheck \
    doxygen \
    graphviz \
    gdb \
    lcov \
    make \
    nodejs \
    npm \
    openocd \
    python3 \
    python3-pip \
    python3-pipx \
    bear
else
  echo "Unsupported package manager. Install these packages manually:"
  echo "ccache clang clang-format clang-tidy clangd cppcheck doxygen gcovr graphviz gdb lcov make nodejs npm openocd python3 pipx bear"
fi

install_platformio

if have pipx; then
  pipx install gcovr || pipx upgrade gcovr || true
  pipx install codespell || pipx upgrade codespell || true
fi

if have npm; then
  sudo npm install -g markdownlint-cli2 || true
fi

cat <<'MSG'

Done.

Next steps:
  1. Restart your shell if pipx changed PATH.
  2. Run: pio --version
  3. Run: .devenvironment/generate-compile-db.sh
MSG

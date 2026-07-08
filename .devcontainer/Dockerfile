FROM mcr.microsoft.com/devcontainers/cpp:1-ubuntu-24.04

ENV DEVENV_TEAM_MODE=0
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PLATFORMIO_CORE_DIR=/home/vscode/.platformio

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    bear \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    clangd \
    cppcheck \
    doxygen \
    gdb-multiarch \
    git-lfs \
    graphviz \
    lcov \
    make \
    nodejs \
    npm \
    openocd \
    pipx \
    python3 \
    python3-pip \
    python3-venv \
    shellcheck \
    udev \
    usbutils; \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  pipx install platformio; \
  pipx install pre-commit; \
  pipx install gcovr; \
  pipx install codespell; \
  npm install -g markdownlint-cli2

RUN set -eux; \
  usermod -aG dialout vscode || true; \
  usermod -aG plugdev vscode || true; \
  mkdir -p /home/vscode/.platformio; \
  mkdir -p /home/vscode/.cache/ccache; \
  chown -R vscode:vscode /home/vscode/.platformio /home/vscode/.cache/ccache

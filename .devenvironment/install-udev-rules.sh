#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rules="$ROOT/.devenvironment/99-platformio-debug-probes.rules"

if [[ ! -f "$rules" ]]; then
  echo "Rules file not found: $rules" >&2
  exit 1
fi

sudo cp "$rules" /etc/udev/rules.d/99-platformio-debug-probes.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

cat <<'MSG'
Installed udev rules.

Unplug and reconnect your board/probe. If serial devices are still not accessible,
make sure your user is in the dialout group:

  sudo usermod -aG dialout "$USER"

Then log out and back in.
MSG


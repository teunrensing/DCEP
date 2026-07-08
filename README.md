# PlatformIO Linux development environment

Drop these files into the root of a PlatformIO project.

## What this adds

- VS Code one-click tasks for build, upload, monitor, tests, linting, clang-tidy, docs, clean, and compile database generation.
- Recommended VS Code extensions for PlatformIO, clangd, Cortex-Debug, Doxygen comments, task buttons, inline diagnostics, TODO tracking, and Markdown.
- `.clang-tidy` tuned for embedded C++ without making every hardware register access painful.
- `.clang-format` for consistent C/C++ formatting.
- `Doxyfile` plus a main page template for generated HTML docs.
- Linux helper scripts under `.devenvironment/`.
- Optional PlatformIO check settings that wire `pio check` to clang-tidy and cppcheck.
- Solo-developer productivity helpers: `Makefile`, `.editorconfig`, `.gitattributes`, `.gitignore`, and optional native Git hooks.
- A Linux dev container with a `DEVENV_TEAM_MODE` flag for enabling team-scale extras later.
- Native Google Test support, firmware size checks, device discovery, doctor diagnostics, and local release artifact packaging.
- Optional Raspberry Pi 4 local review bot that runs on SSH/Git instead of GitHub or GitLab.
- Optional ccache acceleration, native coverage reports, serial monitor logging, dependency snapshots, docs linting, local backups, and Linux debug probe udev rules.

## Install

From your PlatformIO project root:

```bash
cp -an /path/to/platformio-linux-devenvironment/. .
chmod +x .devenvironment/*.sh
```

`cp -an` avoids overwriting files you already have. If you want this bundle to replace existing config, copy individual files deliberately.

Install useful Linux tools:

```bash
.devenvironment/install-linux-tools.sh
```

Open the project in VS Code, install the recommended extensions, then run:

- `Tasks: Run Task` -> `Utility: Generate compile_commands.json`
- `Tasks: Run Task` -> `PlatformIO: Build`
- `Tasks: Run Task` -> `Static Analysis: PlatformIO Check`
- `Tasks: Run Task` -> `Docs: Generate Doxygen`

The recommended `Task Explorer` extension gives you clickable task buttons in the side bar/status area.

## Dev container

This bundle includes a `.devcontainer/` setup for Linux-based PlatformIO work.

It also mounts a named Docker volume at `/home/vscode/.platformio`, so PlatformIO packages survive container rebuilds.

By default it is solo mode:

```jsonc
"containerEnv": {
  "DEVENV_TEAM_MODE": "0"
}
```

When you want the team-scale files, edit `.devcontainer/devcontainer.json`:

```jsonc
"containerEnv": {
  "DEVENV_TEAM_MODE": "1"
}
```

Then rebuild the container.

The container image already includes the tools needed for both modes. The flag controls whether team workflow files are copied into the project and whether pre-commit hooks are installed.

Team mode adds optional files such as:

- `CONTRIBUTING.md`
- `.pre-commit-config.yaml`
- GitHub Actions CI
- PR and issue templates
- an ADR template for architecture decisions

These are copied only when missing, so existing files are not overwritten.

## Solo workflow

For a one-person project, keep the workflow boring and fast:

```bash
make build
make upload
make monitor
make ports
make check
make size
make doctor
make test-native
make coverage
make tidy
make docs
make docs-lint
make release
make monitor-log PORT=/dev/ttyUSB0 BAUD=115200
make deps-snapshot
make cache-stats
make backup
```

If you use more than one PlatformIO environment:

```bash
make build ENV=debug
make upload ENV=release PORT=/dev/ttyUSB0
make tidy ENV=debug
```

Optional Git hooks:

```bash
make hooks
```

The hooks are intentionally small:

- pre-commit formats staged C/C++ files with `clang-format`;
- pre-push runs `pio run` and `pio check`;
- set `SKIP_PIO_PRE_PUSH=1` when you want to push without waiting.

## PlatformIO integration

To let `pio check` and native Google Test use the included settings, add this to the top-level `[platformio]` section in `platformio.ini`:

```ini
[platformio]
extra_configs =
  .devenvironment/platformio-check.ini
  .devenvironment/platformio-native-test.ini
```

If your project already uses `extra_configs`, append the file on a new line:

```ini
[platformio]
extra_configs =
  existing-extra.ini
  .devenvironment/platformio-check.ini
  .devenvironment/platformio-native-test.ini
```

`platformio-native-test.ini` adds a `native` environment for Google Test:

```bash
make test-native
```

See `docs/testing-google-test.md` for a minimal test example and layout advice.

Other useful docs:

- `docs/coverage.md`
- `docs/tooling.md`
- `docs/backups.md`
- `docs/linux-debug-probes.md`

## Local review bot

You can run a small review bot on a Raspberry Pi 4 without GitHub or GitLab.

The workflow is:

```text
developer machine -> git push over SSH -> Raspberry Pi bare repo -> post-receive hook -> checks + review CLI -> Markdown report
```

Start with `docs/review-bot-rpi4.md`.

The bot is intentionally CLI-agnostic. Configure `.reviewbot/review-command.sh` to call the review CLI you want. If no review command is configured, the bot still runs local checks and writes a report.

## Debugging notes

The default VS Code launch configuration uses PlatformIO's active environment. For most boards, PlatformIO already knows the correct debug server and probe from `platformio.ini`.

Useful `platformio.ini` debug options:

```ini
[env:your_env]
debug_tool = stlink
debug_init_break = tbreak setup
monitor_speed = 115200
```

For J-Link or custom OpenOCD setups, edit the `Cortex-Debug: OpenOCD template` configuration in `.vscode/launch.json`.

## Git ignore suggestions

Add these to `.gitignore` if they are not already present:

```gitignore
.pio/
compile_commands.json
docs/doxygen/
```

# Additional solo tooling

## ccache

`ccache` can speed up repeated C/C++ builds.

Enable the optional PlatformIO ccache hook if your project does not already have complex `extra_scripts` behavior. If it does, merge the script deliberately instead of blindly appending it.

```ini
[platformio]
extra_configs =
  .devenvironment/platformio-check.ini
  .devenvironment/platformio-native-test.ini
  .devenvironment/platformio-ccache.ini
```

Useful commands:

```bash
make cache-stats
make cache-clear
```

Disable temporarily:

```bash
PLATFORMIO_DISABLE_CCACHE=1 make build
```

## Dependency checks

```bash
make outdated
make deps-snapshot
```

Snapshots are written under `reports/dependencies/`.

## Serial logs

```bash
make monitor-log PORT=/dev/ttyUSB0 BAUD=115200
```

Logs are written under `logs/`.

## Docs linting

```bash
make docs-lint
```

This uses `codespell` and `markdownlint-cli2` when available.

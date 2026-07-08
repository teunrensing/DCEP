# Native test coverage

The environment includes a `native_coverage` PlatformIO environment and a `make coverage` command.

Enable the extra config in `platformio.ini`:

```ini
[platformio]
extra_configs =
  .devenvironment/platformio-check.ini
  .devenvironment/platformio-native-test.ini
```

Run:

```bash
make coverage
```

Outputs:

```text
coverage/index.html
coverage/coverage.xml
coverage/coverage.txt
```

Coverage is intended for hardware-independent logic that can compile under `platform = native`.


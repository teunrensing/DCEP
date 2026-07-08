# Dependency notes

Pin dependencies in `platformio.ini` so a build from next month behaves like today's build.

Prefer this:

```ini
[env:your_env]
platform = espressif32 @ 6.9.0
framework = arduino
lib_deps =
  bblanchon/ArduinoJson @ 7.0.4
  adafruit/Adafruit BusIO @ 1.16.1
```

Over this:

```ini
platform = espressif32
lib_deps =
  bblanchon/ArduinoJson
```

Useful commands:

```bash
pio pkg list
pio pkg outdated
pio pkg update
```

Update deliberately, build, flash, and note important changes in your project notes or changelog.


# Debugging notes

Fill this in once per board. Future-you will be grateful.

## Hardware

- Board:
- MCU:
- Debug probe:
- Upload port:
- Serial monitor baud:
- Power source:

## Wiring

| Probe | Target |
| --- | --- |
| GND | GND |
| SWDIO / TMS | |
| SWCLK / TCK | |
| NRST | |
| VTref / 3V3 sense | |

## PlatformIO settings

```ini
[env:your_env]
build_type = debug
debug_tool = stlink
debug_init_break = tbreak setup
monitor_speed = 115200
```

Common `debug_tool` values include `stlink`, `jlink`, `cmsis-dap`, `blackmagic`, `esp-prog`, and `custom`.

## Linux permissions

Serial and debug probes usually need group access:

```bash
sudo usermod -aG dialout "$USER"
```

Log out and back in after changing groups.

Check connected devices:

```bash
make ports
make doctor
```

## VS Code

Use `PlatformIO: Debug active environment` first. Only use the `Cortex-Debug: OpenOCD template` when PlatformIO's built-in debug flow is not enough.


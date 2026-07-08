# Linux debug probes and serial devices

Install common udev rules:

```bash
make udev-rules
```

Then unplug and reconnect the board or probe.

Serial devices usually also require the `dialout` group:

```bash
sudo usermod -aG dialout "$USER"
```

Log out and back in after changing groups.

## Covered devices

The included `.devenvironment/99-platformio-debug-probes.rules` covers common vendor IDs for:

- ST-Link
- SEGGER J-Link
- CMSIS-DAP / DAPLink
- Espressif USB/JTAG and serial
- FTDI serial adapters
- Silicon Labs CP210x serial adapters
- WCH CH340/CH341 serial adapters

If your probe is not detected, run:

```bash
lsusb
make ports
make doctor
```

Then add a specific rule for the missing vendor/product ID.


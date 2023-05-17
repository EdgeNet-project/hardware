# EdgeNet appliances

This repository contains the boot scripts for EdgeNet's bare metal nodes.

## Odroid N2

N2 boards have three main memories:
- A 8MB flash SPI with [petitboot][petitboot] preinstalled
- A eMMC slot
- A SD slot

Our current boot procedure is as follows:
1. petitboot loads the [`boot/odroid-n2.sh`](/boot/odroid-n2.sh) script from GitHub.
2. The script fetch a minimal Ubuntu image and write it to the eMMC.
3. petitboot boots from the eMMC.

This procedure is currently repeated on every boot.

### Initial setup

1. Set the `MMC/SPI` switch at the rear of the board to `SPI`
2. Plug a keyboard and a screen, or connect via the [serial port](https://wiki.odroid.com/accessory/development/usb_uart_kit)
3. Plug an Ethernet cable and the power cord
4. Initialize the hardware clock:
```bash
# Replace with the actual date and time
date -s "2022-06-08 21:59"
hwclock -w
```

5. Set the boot script url:
```bash
fw_setenv petitboot,userscript https://odroid.edge-net.io/odroid-n2.sh
```
The provided URL is an alias to https://raw.githubusercontent.com/EdgeNet-project/hardware/main/boot/odroid-n2.sh

6. Update petitboot (we require version `20220317` at-least):
```bash
pb-update
```

7. Verify that the board runs the script

## Debugging

```bash
journalctl -fu edgenet
journalctl -fu kubelet
```

[node]: https://github.com/EdgeNet-project/node
[petitboot]: https://forum.odroid.com/viewtopic.php?t=33873

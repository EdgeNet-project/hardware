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
3. The script downloads the EdgeNet bootstrap script from the [node][node] repository and set it to run on boot.
4. petitboot boots from the eMMC.

This procedure is currently repeated on every boot.

### Initial setup

1. Set the `MMC/SPI` switch at the rear of the board to `SPI`
2. Plug a keyboard and a screen (alternatively, connect via the serial port)
3. Plug the power cord
4. Update petitboot (we require version `20220317` at-least):
```bash
pb-update
# ctrl+alt+del to reboot
```
5. Set the boot script url:
```bash
fw_setenv petitboot,userscript=http://raw.githubusercontent.com/EdgeNet-project/hardware/main/boot/odroid-n2.sh
```

[node]: https://github.com/EdgeNet-project/node
[petitboot]: https://forum.odroid.com/viewtopic.php?t=33873

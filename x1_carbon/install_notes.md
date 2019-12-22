[Wiki page for X1 Carbon](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_7))

# BIOS
 - BIOS config menu: F1
 - Disable secure boot
 - Set sleep mode to 'Linux' -> `Config -> Power -> Sleep State`

## Kernel DMA Protection:

Arch wiki recommends enabling thunderbolt BIOS assist mode to improve battery
life, but this feature is not accessible in bios by default.
The reason for this Kernel DMA protection is enabled by default in the BIOS.

Kernel DMA protection found in `Security -> Virtualization`

# Network in boot mode

 - Ethernet through dongle
   * Run `dhcpd` after connected to get dhcp running on correct interface

# Post-install

## Graphics
 - ~~Not installing x86-video-intel package as per KDE wiki recommendation~~
   * xf86-video-intel was necessary to get `xinit` working

```bash
pacman -S mesa mesa-demos
```

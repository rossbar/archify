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

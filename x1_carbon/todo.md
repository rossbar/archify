 - [ ] Test battery life with/without thunderbolt bios assist
   - If no difference, update [arch wiki](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_7))
   - If significant difference, research how to safely disable Kernel DMA
 - [ ] Bios updates with fwupd
   - [ ] Check BIOS version
 - [x] [Deal with throttling](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_7)#throttled)
   * Using throttled package
   * Useful commands for testing results:
     - CPU temps (and config values): `watch -n 0.5 'sensors | head'`
       See [here](https://wiki.archlinux.org/index.php/Lm_sensors) for correct config of lm_sensors
     - CPU freqs: `watch -n 0.5 'cat /proc/cpuinfo | grep MHz'`
     
 - [ ] Investigate [TLP](https://wiki.archlinux.org/index.php/TLP) for battery
       optimization
 - [x] Volume control
   * Followed arch wiki instructions verbatim - worked
 - [ ] Test microphone
 - [ ] swap file
 - [ ] [install Vulkan?](https://wiki.archlinux.org/index.php/Vulkan)

# General post-install instructions

## Network

1. Verify drivers have been loaded: `lspci -k | less`. Look for mentions of 
   "Network" and verify there is an entry mentioning `Kernel driver in use:`

2. Check available interfaces: `ip link`

3. Make sure desired interface is up: `ip link set <interface> up`

### Wired-only network

Use the dhcp client `dhcpcd` to get this working. No interface-specific
configuration is required for wired-only systems. Use systemd to launch 
service at startup:

```bash
systemctl enable --now dhcpcd
```

Reboot to see if it worked.

### Wireless (e.g. laptops)

`dhcpcd` in conjunction with `wpa_supplicant`. In my experience, it is best to
configure these for the specific interface. Start with dhcp:

```bash
systemctl enable dhcpcd@<interface>
```

#### Discover wireless networks

```bash
iw <interface> scan | less
```

#### Configure wpa\_supplicant

```bash
# WARING: This command requires you to type the network password in plain text
# on the cli
wpa_passphrase <network_ssid> <password> >> /etc/wpa_supplicant/wpa_supplicant-<interface>.conf
```

After running the command, make sure to go into the 
`wpa_supplicant-<interface>.conf` and delete the plain-text line containing
the un-hashed password.

Note: run this command any time you want to add a new network.

Note: To add an unsecure (e.g. public) network, add the following entry to 
`wpa_supplicant-<interface>.conf`:

```
network={
  ssid="MYSSID"
  key_mgmt=None
}
```

#### Enable `wpa_supplicant` at startup

```bash
systemctl enable wpa_supplicant@interface
```

Reboot.

## User management

### Add a new user:

```bash
useradd -m -s /bin/bash <username>
passwd <username>
```

Consider adding new user to additional gropus as necessary: see 
[this list](https://wiki.archlinux.org/index.php/Users_and_groups#Group_list)
for some common groups.

### Configure sudo

Using `visudo`, add the following to `/etc/sudoers`:

```
<username> ALL=(ALL) ALL
```

## Graphics drivers

Note: recommend installing/updating graphics drivers before installing 
Xorg/desktop environment.

1. Figure out what your graphics controller is: `lspci | grep -e VGA -e 3D`

Follow card- or system-specific instructions for installing drivers.

## Desktop environment

### Xorg
Recommend the `xorg` group: `pacman -S xorg xorg-xinit`

### KDE

```
pacman -S plasma kde-applications
```

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

`dhcpcd` in conjunction with `wpa_supplicant`.

```bash
systemctl enable dhcpcd
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

`DiscoverNotifier` has caused crashes on my systems before. I never use the
kde software discoverer, so remove this to improve system stability:

```bash
pacman -R discover
```

Also disable baloo file indexer (bugs here can cause it to peg a whole cpu):

```bash
balooctl disable
```

## Configure git, vim, bash

Make sure everything is installed: `pacman -S git vim`

Run the configuration scripts:

```bash
cd scripts/
./configure_git.sh
./configure_bash.sh
./vim_upgrade.sh
```

## Python

The default arch installation should have the bleeding-edge version of python.
It is recommended that python is installed on the system parallel to the
system python to avoid issues with building wheels when the minor rev. number
is bumped (i.e. 3.7 -> 3.8).

### Install "stable" python

1. Download the source for the version you want.

2. Make sure prereqs are installed: `pacman -S tk bzip2`

3. Unzip the tar, configure and build
   
   ```bash
   ./configure --enable-optimizations
   make -j8
   make test
   sudo make install
   ```

   Note: As of 3.7.5, tests are automatically run sequentially with the `make`
   command. Recommend killing the `make` process here and explicitly running
   `make test`, which will run the test suite using all available cores.

### Install pip

Install pip with the *system* python. Rely on `virtualenv` to handle switching
between different python versions.
The following installs pip in `$HOME/.local/bin` by default. If this isn't
what you want, check out the get-pip config options.

```bash
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
# Add pip location to path
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
```

### Install virtualenv

```bash
pip install --user virtualenv virtualenvwrapper
# Configure
echo 'mkdir -p $HOME/.virtualenvs' >> $HOME/.bashrc
echo 'export WORKON_HOME=$HOME/.virtualenvs' >> $HOME/.bashrc
echo 'source $HOME/.local/bin/virtualenvwrapper.sh' >> $HOME/.bashrc
```

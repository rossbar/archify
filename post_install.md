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

### Miniconda

Prefer pip for dependency management as it is the standard python tool.
However, there are situations where `pip` is insufficient for dependency
management. For example, some projects have dependencies that exist outside the
python ecosystem (e.g. compilers for `numba`; ruby/jekyll for `jupyterbook`).
This gets hairy on arch as arch tends to have the absolute newest version of
everything whereas the dependencies for these python packages tend not to be
bleeding edge. Instead of gumming up the system with multiple library versions,
you can use `conda` to manage these external dependencies.
For example, if you need `jekyll` for `jupyterbook`, `conda` can handle the
creation of a local environment with `ruby` installed, circumventing the need
to install `ruby` on the system iteself.

The following will install `conda` with (hopefully) the smallest possible 
footprint and allow you to switch to use `conda` as a secondary environment
manager **without blowing up the existing pip configuration**.

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -f -p $HOME/miniconda
export PATH=$HOME/miniconda/bin:$PATH
conda config --set always_yes yes
conda update conda
```

Then add the following to your shell environment:

```bash
alias use-conda='export PATH=$HOME/miniconda/bin:$PATH'
```

Close the current terminal session to get rid of the temporary `PATH` 
specification.

The system should now be configured to use `pip` and `virtualenv` by default,
but allowing you to use `conda` instead in a given terminal session with
`use-conda`.

For example, to set up an environment with `jekyll`:

```bash
use-conda
conda create -n jekyllenv
# Enter the environment
source activate jekyllenv
conda install -c conda-forge rb-github-pages
```

**NOTE**: To enter environments without `conda` futzing with your `BASH_ENV`,
use `source activate <envname>` instead of `conda activate <envname>`. 
Exiting the environment is still done by `conda deactivate`.

## Configure `ssh`

*After* ssh keys have been all set up, the following procedure can be used to
configure `ssh-agent`/`ssh-add` to run automatically for each X session

 1. `pacman -S x11-ssh-askpass`

 1. add `ssh-agent` wrapper to `.xinitrc`:

    ```bash
    export SSH_ASKPASS=ssh-askpass
    eval $(ssh-agent)
    ...
    exec startplasma-x11
    ```

 2. Make sure `x11-ssh-askpass` is accessible on `PATH`:

    ```bash
    ln -sv /usr/lib/ssh/x11-ssh-askpass ~/.local/bin/ssh-askpass
    ```

 3. Add `ssh-add` to kde autostart scripts
    
    ```bash
    ln -sv /usr/bin/ssh-add $HOME/.config/autostart-scripts/ssh-add
    ```

Reboot. The next time an X session is launched, an ugly little prompt will ask
for passwords to unlock the ssh keys. The key will then be available for the
duration of the X session.

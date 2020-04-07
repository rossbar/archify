# Installation Notes

This is basically the
[arch install wiki](https://wiki.archlinux.org/index.php/Installation_guide)
pared down and personalized.

### 1. Verify boot mode

```bash
ls /sys/firmware/efi/efivars
```

### 2. Connect to internet

Wired connections (including dongles) will work OOB with `dhcpcd`.

### 3. Update system clock

```bash
timedatectl set-ntp true
```

### 4. Partition disk(s)

Identify devices: `lsblk`

Partition with: `fdisk`

**Default Partition Scheme**

| Mount point | Partition       | Partition Type | Size |
|-------------|-----------------|----------------|------|
| `/mnt/efi`  | `/dev/nvme0n1p1`| EFI system     | +512M|
| `/mnt`      | `/dev/nvme0n1p2`| Linux          | rest |

### 5. Format Partitions

```
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
```

### 6. Set up swap file

```bash
fallocate -l 1024m /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### 7. Mount filesystems

```bash
mkdir -p /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi
mount /dev/nvme0n1p2 /mnt
```

Make sure all partitions are mounted so they can be auto-gen'ed by `genfstab`.

### 8. Select mirrors

\#1: `http://mirrors.ocf.berkeley.edu/archlinux/$repo/os/$arch`

\#2: `http://mirrors.cat.pdx.edu/archlinux/$repo/os/$arch`

### 8b. Update keyring

If you're using an old usb img, it might contain bad/expired keys. Fix with:

```bash
pacman -Sy archlinux-keyring
```

### 9. Install initial packages

```bash
# Essentials
pacstrap /mnt base linux linux-firmware
# Install if internet is fast. Good idea to install internet related packages now
pacstrap /mnt base-devel vim man-db man-pages texinfo dhcpcd wpa_supplicant iputils iw
```

### 10. Generate `fstab`

```bash
genfstab -U /mnt >> /mnt/etc/fstab
# Add swapfile
echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
```

## Change root to new system

```bash
arch-chroot /mnt
```

### 1. Set time zone
```bash
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc
```

### 2. Localization

Uncomment out relevant lines from `/etc/locale.gen`

```bash
...
#en_PH.UTF-8 UTF-8
#en_PH ISO-8859-1
#en_SC.UTF-8 UTF-8
#en_SG.UTF-8 UTF-8
#en_SG ISO-8859-1
en_US.UTF-8 UTF-8
en_US ISO-8859-1
#en_ZA.UTF-8 UTF-8
#en_ZA ISO-8859-1
#en_ZM UTF-8
#en_ZW.UTF-8 UTF-8
#en_ZW ISO-8859-1
...
```

```bash
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

### 3. Network configuration

Choose a name for the computer.

```bash
echo "myhostname" >> /etc/hostname
```

Modify `/etc/hosts` with chosen name:
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   myhostname.localdomain myhostname
```

### 4. `passwd`

### 5. Install grub

```bash
pacman -S grub
grub-install --target=x86_64-efi --efi-directory=/mnt/efi --bootloader-id=GRUB
```

Install necessary microcode package before configuring grub:
```bash
pacman -S <intel/amd>-ucode
grub-mkconfig -o /boot/grub/grub.cfg
```

## Exit chroot

1. `exit`

2. `umount -R /mnt`

3. `reboot`

## *Cross Fingers*

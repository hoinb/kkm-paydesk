# kkm-paydesk

Paydesk suite for Kinderkleidermarkt St. Peter. Based on Flohmarkthelfer 


## Scope
- Debian 12
- Gnome Desktop

## Step by step

### Install OS
Debian/Gnome
user: kkmarkt / pw: ...
root pw: ...

### OS tuning

#### Install some useful utilities
`apt install -y geany terminator htop curl git`

#### sudo for user kkmarkt
add user kkmarkt user to /etc/sudoers

#### Enable non-integer scaling for Gnome
`$ gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"`

[https://www.dedoimedo.com/computers/gnome-hd-scaling.html]

### Install Virtual Box Guest extension
(VM only)
[https://kifarunix.com/install-virtualbox-guest-additions-on-debian-11/]

### Auto-Login
[https://help.gnome.org/admin/system-admin-guide/stable/login-automatic.html.en]

### KKM-Applikationen installieren (kkm-paydesk)

```
$ cd ~
$ git clone https://github.com/hoinb/kkm-paydesk.git
$ cd kkm-paydesk
$ ./install/install.sh
```

### Aufräumen (Vorbereitung für Image-Erstellung)

```
$ rm -rf ~/.cache
$ rm -rf ~/kkm-paydesk
$ rm -rf ~/Downloads/*
$ rm -rf ~/.mozilla/firefox
$ rm ~/.bash_history
```

# Lessons learned

## Lessons learned: restoring a Clonezilla image onto different hardware (2026-10)

Background: a Debian 12 image from a ThinkPad X280 (512 GB NVMe) was restored
onto a Fujitsu Lifebook (256 GB SATA). It worked, but needed manual fixes,
which the next master image should make unnecessary.

### 1. Make the image bootable on any machine
- Problem: "No bootable device". The UEFI boot entry lives in the old
  machine's firmware (NVRAM), and Debian doesn't install the fallback file
  `\EFI\BOOT\BOOTX64.EFI` by default.
- Before imaging, run on the master:
  ```bash
  echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | debconf-set-selections
  grub-install --target=x86_64-efi --force-extra-removable
  update-grub
  ```
- Fix after the fact: boot grml, chroot into the restored root (with `/boot/efi`,
  `/dev`, `/proc`, `/sys`, `/run` bind-mounted), then run the same commands.

### 2. Keep partitions smaller than the smallest disk
- Clonezilla/partclone restores each filesystem at its original size, so a
  partition can't be restored into a smaller one.
- Size the master's partitions to fit the smallest SSD in the fleet. Grow them
  on each machine after restoring if needed (`growpart` + `resize2fs`).
- Restoring onto a smaller disk: in Clonezilla Expert mode use `-icds`
  (skip the disk size check) and `-k0` (use the partition table from the
  image). Never use `-k1`: it shrinks partitions below their filesystem size.

### 3. Clean out ConnMan before imaging
- Problem: the built-in LAN stayed down (no driver issue). The image's
  `/var/lib/connman/settings` had `[Wired] Enable=false`.
  Fix: `connmanctl disable ethernet && connmanctl enable ethernet`.
- Saved Wi-Fi networks are tied to each Wi-Fi card's MAC address
  (`wifi_<mac>_...`) and don't carry over to other hardware.
  Instead, ship a provisioning file that doesn't depend on the MAC:
  ```ini
  # /var/lib/connman/guest-wifi.config
  [service_guest]
  Type = wifi
  Name = <ssid>
  Passphrase = <passphrase>
  ```
- Don't also configure interfaces in `/etc/network/interfaces` (ifupdown).
  With both active, an interface gets two IP addresses.

### 4. Give each machine its own identity after cloning
A clone keeps the master's machine-id, SSH host keys and hostname. After each restore, run:
```bash
rm /etc/machine-id && systemd-machine-id-setup
rm /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server
hostnamectl set-hostname <name>
```

### 5. Not a problem: NVMe ↔ SATA, Intel NIC/Wi-Fi model changes
- Debian's initramfs (`MODULES=most`) includes both the NVMe and SATA drivers.
- `/etc/fstab` uses UUIDs, so device names don't matter.
- Keep `non-free-firmware` enabled in apt and `firmware-iwlwifi` /
  `firmware-realtek` / `firmware-misc-nonfree` installed in the image.
- Check that the firmware's SATA mode is set to AHCI, not RAID/RST.


## Lessons learned: Google Drive via rclone (2026-10)

`install/install.sh` runs `rclone config` interactively. If that step doesn't
produce a working remote, the rest of the install fails too: the
`secondhand-gui` jar is downloaded from Google Drive, and the script server
part comes after that download.

### Setting up the remote (first install)
- Remote name, exactly: `gdrive-info-at-kinderkleidermarkt-st-peter-de`
- Type: `drive`, scope: `drive` (full access)
- `client_id` / `client_secret`: use the project's own Google OAuth client.
  Paste the values from an existing notebook's `~/.config/rclone/rclone.conf`.
  **Never type a name or hostname here.** That's how one notebook ended up
  with `client_id = kkm-kasse-06` and no working token.
- Each notebook gets its **own token** (its own Google login) but shares the
  same OAuth client. Don't copy the `token = ...` line between notebooks.
- The Google login needs a browser, so run `rclone config` in a terminal
  **on the notebook's desktop**, not over SSH. Answer "Use web browser to
  automatically authenticate" with `y`, then sign in with the
  info@kinderkleidermarkt-st-peter.de account.
- Afterwards: `chmod 600 ~/.config/rclone/rclone.conf`

### Fixing a remote without a working token
`rclone config reconnect <remote>:` fails with "backend does not support
reconnect or authorize" if the remote never had a token. Use the editor instead:
`rclone config` → `e` (edit) → choose the remote → press Enter on every
prompt to keep the existing values (check that `client_id` shows the real ID
as default) → advanced config `n` → web browser `y` → Shared Drive `n` →
keep `y` → `q`.

### Check
```bash
rclone lsf gdrive-info-at-kinderkleidermarkt-st-peter-de:/kkm-inst
```
must list `secondhand-gui-*.jar`.

### Running install.sh again
The script can be run again safely. At the `rclone config` step, answer `q` to
keep the existing remote. A reboot afterwards may be needed before the script
server runs cleanly.


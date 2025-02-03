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
$ git checkout https://github.com/hoinb/kkm-paydesk.git
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

# apt -y autoremove && apt clean
# rm -rf ~/.cache
```


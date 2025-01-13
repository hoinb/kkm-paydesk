#!/bin/bash

BASEDIR="/home/$USER/kkm-paydesk"
echo $BASEDIR


# Install required packages with APT
sudo apt update \
  || { echo "apt update failed." ; exit 1; }
sudo apt install -y \
  python3-pip \
  || { echo "apt install failed." ; exit 2; }

# Create Python venv and install required pip packages


# Install Java JRE
rm -rf "$BASEDIR/flohmarkthelfer/jre/*"
l_jreTgzfile=""
if [ "amd64" = "$(dpkg --print-architecture)" ]; then
  l_jreTgzfile=$(ls -1 $BASEDIR/install/java-jre/*-linux_x64.tar.gz)
  echo "$l_jreTgzfile"
elif [ "i386" = "$(dpkg --print-architecture)" ]; then
  l_jreTgzfile=$(ls -1 $BASEDIR/install/java-jre/*-linux_i686.tar.gz)
  echo "$l_jreTgzfile"
else
  echo "cannot detect system architecture ($(dpkg --print-architecture))" ; exit 5;
fi

mkdir -p "$BASEDIR/flohmarkthelfer/jre" \
    && tar xzf $l_jreTgzfile -C "$BASEDIR/flohmarkthelfer/jre" \
  || { echo "cannot extract Java Runtime Environment" ; exit 4; }


#!/bin/bash


#
# usage:
# $ set -o allexport && source kkm-paydesk.env && set +o allexport && ./install/install.sh
#

echo ">> $KKM_PAYDESK_BASEDIR"

# Install required packages with APT
sudo apt update \
  || { echo "apt update failed." ; exit 1; }

sudo apt install -y \
  python3-pip \
  || { echo "apt install failed." ; exit 2; }

# Create Python venv and install required pip packages

# TODO


source ./kkm-paydesk.env

# Install Java JRE
rm -rf "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre/*"
l_jreTgzfile=""
if [ "amd64" = "$(dpkg --print-architecture)" ]; then
  l_jreTgzfile=$(ls -1 $KKM_PAYDESK_BASEDIR/install/java-jre/*-linux_x64.tar.gz)
  echo "$l_jreTgzfile"
elif [ "i386" = "$(dpkg --print-architecture)" ]; then
  l_jreTgzfile=$(ls -1 $KKM_PAYDESK_BASEDIR/install/java-jre/*-linux_i686.tar.gz)
  echo "$l_jreTgzfile"
else
  echo "cannot detect system architecture ($(dpkg --print-architecture))" ; exit 5;
fi

mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" \
    && tar xzf $l_jreTgzfile -C "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" --strip-components 1 \
  || { echo "cannot extract Java Runtime Environment" ; exit 6; }

# Ensure that required folders for Flohmarkthelfer are existing
mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/data" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/log" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/sync" \
  || { echo "cannot create required folders" ; exit 7; }

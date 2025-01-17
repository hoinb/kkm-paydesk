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
  python3-venv \
  || { echo "apt install failed." ; exit 2; }

# Create Python venv and install required pip packages

# TODO


#
# SECTION 1   ---   Basic Setup
#
source ./kkm-paydesk.env \
  || { echo "cannot source env variables" ; exit 11; }




#
# SECTION 2  ---   Install Flohmarkthelfer
#

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
  echo "cannot detect system architecture ($(dpkg --print-architecture))" ; exit 21;
fi

mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" \
    && tar xzf $l_jreTgzfile -C "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" --strip-components 1 \
  || { echo "cannot extract Java Runtime Environment" ; exit 22; }

# Ensure that required folders for Flohmarkthelfer are existing
mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/data" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/log" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/sync" \
  || { echo "cannot create required folders" ; exit 23; }
  
  

#
# SECTION 3   ---   Install Bugy Script Server
#
cd $KKM_PAYDESK_BASEDIR \
  && rm -rf ./python-venv \
  && mkdir ./python-venv \
  && python3 -m venv ./python-venv \
  ||  { echo "cannot install python venv" ; exit 34; }
./python-venv/bin/pip install \
    tornado \
  ||  { echo "cannot install pip packages" ; exit 35; }
wget "https://github.com/bugy/script-server/releases/download/$KKM_PAYDESK_SCRIPT_SERVER_TAG/script-server.zip" \
  ||  { echo "cannot download script-server.zip" ; exit 35; }
rm -rf ./bugy-script-server \
  && mkdir -p bugy-script-server \
  && unzip -d bugy-script-server script-server.zip \
  && rm script-server.zip \
  ||  { echo "cannot extract script-server.zip" ; exit 35; }
  

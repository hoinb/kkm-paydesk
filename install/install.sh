#!/bin/bash


#
# SECTION 1   ---   Basic Setup
#
source ./kkm-paydesk.env \
  || { echo "cannot source env variables" ; exit 11; }

# Install required packages with APT
sudo apt update \
  || { echo "apt update failed." ; exit 12; }

sudo apt install -y \
  python3-pip \
  python3-venv \
  pdftk \
  || { echo "apt install failed." ; exit 13; }


#
# Section 2   ---   Connect to Google Drive (Backup for Flohmarkthelfer data) via RClone
#
if ( ! which rclone ); then
  { sudo -v ; curl https://rclone.org/install.sh | sudo bash; } \
    ||  { echo "cannot install RClone" ; exit 21; }
fi

if ( systemctl --user list-unit-files "kkm-sync-flohmarkthelfer-to-google-drive.timer" ) ; 
then
  systemctl --user stop kkm-sync-flohmarkthelfer-to-google-drive.timer \
    ||  { echo "cannot stop kkm-sync-flohmarkthelfer-to-google-drive" ; exit 22; }
fi

rclone config

mkdir -p ~/.config/systemd/user \
  && rm  -f ~/.config/systemd/user/kkm-sync-flohmarkthelfer-to-google-drive.* \
  && cp ./install/kkm-sync-flohmarkthelfer-to-google-drive.* ~/.config/systemd/user \
  && sed -i "/WorkingDirectory=/ s/=.*/=${KKM_PAYDESK_BASEDIR//\//\\/}/" ~/.config/systemd/user/kkm-sync-flohmarkthelfer-to-google-drive.service \
  ||  { echo "cannot extract systemd service for script-server" ; exit 23; }

systemctl --user daemon-reload \
  && systemctl --user enable --now kkm-sync-flohmarkthelfer-to-google-drive.timer \
  ||  { echo "cannot launch kkm-sync-flohmarkthelfer-to-google-drive via systemd" ; exit 24; }


#
# SECTION 3  ---   Install Flohmarkthelfer
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
  echo "cannot detect system architecture ($(dpkg --print-architecture))" ; exit 31;
fi

mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" \
    && tar xzf $l_jreTgzfile -C "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/jre" --strip-components 1 \
  || { echo "cannot extract Java Runtime Environment" ; exit 32; }

# Ensure that required folders for Flohmarkthelfer are existing
mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/data" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/lib" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/log" \
    && mkdir -p "$KKM_PAYDESK_BASEDIR/flohmarkthelfer/sync" \
  || { echo "cannot create required folders" ; exit 33; }
  
echo "DEBUG --- KKM_SECONDHAND_GUI_JAR=\"$KKM_SECONDHAND_GUI_JAR\""

# Check if secondhand-gui jar is set
test -n "$KKM_SECONDHAND_GUI_JAR" \
  || { echo "ENV variable for secondhand-gui jar is not set" ; exit 34; }
  
# Download secondhand-gui jar
rclone copy gdrive-info-at-kinderkleidermarkt-st-peter-de:/kkm-inst/$KKM_SECONDHAND_GUI_JAR ./flohmarkthelfer/lib \
  || { echo "cannot download secondhand-gui jar" ; exit 35; }
  
# Add a .desktop file to Autostart and Desktop
mkdir -p ~/.config/autostart \
    && cp ./install/flohmarkthelfer.desktop  ~/.config/autostart \
    && chmod +x ~/.config/autostart/flohmarkthelfer.desktop \
    && sed -i "/Icon=/ s/=.*/=${KKM_PAYDESK_BASEDIR//\//\\/}\/flohmarkthelfer\/floh.png/" ~/.config/autostart/flohmarkthelfer.desktop \
    && sed -i "/Path=/ s/=.*/=${KKM_PAYDESK_BASEDIR//\//\\/}/" ~/.config/autostart/flohmarkthelfer.desktop \
    && cp ~/.config/autostart/flohmarkthelfer.desktop ~/.local/share/applications/ \
  ||  { echo "cannot install ~/.config/autostart/flohmarkthelfer.desktop" ; exit 36; }



#
# SECTION 4   ---   Install Bugy Script Server
#
if ( systemctl --user list-unit-files "bugy-script-server.service" ) ; 
then
  systemctl --user stop bugy-script-server \
    ||  { echo "cannot stop script server" ; exit 41; }
fi

cd $KKM_PAYDESK_BASEDIR \
  && rm -rf ./python-venv \
  && mkdir ./python-venv \
  && python3 -m venv ./python-venv \
  ||  { echo "cannot install python venv" ; exit 42; }

./python-venv/bin/pip install \
    tornado \
  ||  { echo "cannot install pip packages" ; exit 43; }

wget -q "https://github.com/bugy/script-server/releases/download/$KKM_PAYDESK_SCRIPT_SERVER_TAG/script-server.zip" \
  ||  { echo "cannot download script-server.zip" ; exit 44; }

rm -rf ./bugy-script-server \
  && mkdir -p bugy-script-server \
  && unzip -q -d bugy-script-server script-server.zip \
  && rm script-server.zip \
  ||  { echo "cannot extract script-server.zip" ; exit 45; }

mkdir -p ~/.config/systemd/user \
  && rm  -f ~/.config/systemd/user/bugy-script-server.service \
  && cp ./install/bugy-script-server.service ~/.config/systemd/user \
  && sed -i "/WorkingDirectory=/ s/=.*/=${KKM_PAYDESK_BASEDIR//\//\\/}\/bugy-script-server/" ~/.config/systemd/user/bugy-script-server.service \
  ||  { echo "cannot extract systemd service for script-server" ; exit 46; }

systemctl --user daemon-reload \
  && systemctl --user enable --now bugy-script-server \
  ||  { echo "cannot launch script-server via systemd" ; exit 47; }
  
mkdir -p ~/.config/autostart \
  && cp ./install/xhost-plus-local.desktop  ~/.config/autostart \
  && chmod +x ~/.config/autostart/xhost-plus-local.desktop \
  ||  { echo "cannot install ~/.config/autostart/xhost-plus-local.desktop" ; exit 48; }
  
cp ./install/kkm-script-server.desktop ~/.local/share/applications/ \
  ||  { echo "cannot install Desktop icon" ; exit 49; }

#!/bin/sh

SECONDHAND_JAR="$(ls -1 $KKM_PAYDESK_BASEDIR/flohmarkthelfer/lib/secondhand-gui-5.*.jar)"
CONFIG_FILE_TEMPLATE="./config.properties.TEMPLATE"
CONFIG_FILE="./config.properties"

cd $KKM_PAYDESK_BASEDIR/flohmarkthelfer

# prepare config file
rm -f $CONFIG_FILE
cp $CONFIG_FILE_TEMPLATE $CONFIG_FILE
sed -i "/buttons.all=/ s/=.*/=$KKM_FLOHMARKTHELFER_BUTTONS_ALL/" $CONFIG_FILE
sed -i "/peer.name=/ s/=.*/=$HOSTNAME/" $CONFIG_FILE

# lauch Flomarkthelfer
$JAVA_HOME/bin/java -jar $SECONDHAND_JAR

cd -



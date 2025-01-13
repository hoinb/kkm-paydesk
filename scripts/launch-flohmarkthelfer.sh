#!/bin/sh

export SECONDHAND_JAR="$(ls -1 $KKM_PAYDESK_BASEDIR/flohmarkthelfer/lib/secondhand-gui-5.*.jar)"
echo $SECONDHAND_JAR

cd $KKM_PAYDESK_BASEDIR/flohmarkthelfer && $JAVA_HOME/bin/java -jar $SECONDHAND_JAR
cd -



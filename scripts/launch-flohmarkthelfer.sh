#!/bin/sh

# Configuration for Adopt OpenJDK 8 on Debian 10. See also:
# <https://linuxize.com/post/install-java-on-debian-10/>
if [ $(arch) == "i686"] 
then
  echo "Using Java Runtime for 64-bit platform (x86_64)"
  export JAVA_HOME="./zulu8.80.0.17-ca-jre8.0.422-linux_x64"
else
  echo "Using Java Runtime for 32-bit platform ($(arch))"
  export JAVA_HOME="./zulu8.80.0.17-ca-jre8.0.422-linux_i686"
fi

# export SECONDHAND_JAR=bin/secondhand-gui-5.8.0.jar
export SECONDHAND_JAR=bin/secondhand-gui-5.9.0-SNAPSHOT-20230829.jar

$JAVA_HOME/bin/java -jar $SECONDHAND_JAR

# sleep 999

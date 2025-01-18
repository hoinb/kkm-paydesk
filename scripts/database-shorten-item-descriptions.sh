#!/bin/bash

# Driver for H2 Database, version 1.4.200
# [http://h2database.com/html/download-archive.html]
export CLASSPATH=lib/h2-1.4.200.jar
export WARNING_MESSAGE="ACHTUNG - Dieses Programm wird die lokale Datenbank dauerhaft verändern. Fortsetzen mit ENTER"

echo "Lokale Datenbank anpassen (Artikel-Bezeichner verkürzen für Ausdruck Verkäufer-Abrechnung)"
read -p "$WARNING_MESSAGE"

cd flohmarkthelfer

$JAVA_HOME/bin/java -cp $CLASSPATH org.h2.tools.Shell \
  -driver "org.h2.Driver" \
  -url "jdbc:h2:./floh" \
  -user sa \
  -sql "UPDATE PUBLIC.ITEMS SET DESCRIPTION = concat(SUBSTRING(DESCRIPTION, 1,26), ' ...') WHERE LENGTH (DESCRIPTION)>30;" \
  ||  { echo "cannot launch H2 Shell"; exit 1; }

echo "Datenbank wurde angepasst."

cd -

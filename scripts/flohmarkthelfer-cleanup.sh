#!/bin/bash

cd flohmarkthelfer

export WARNING_MESSAGE="ACHTUNG - Alle lokalen Daten werden gelöscht. Fortsetzen mit ENTER"

read -p "$WARNING_MESSAGE"

rm -f ./floh.mv.db
rm -f ./verkaeufer-abrechnung-overlay.pdf
rm -rf data/*
rm -rf sync/*
rm -rf log/*

echo "Daten wurden gelöscht."

cd -

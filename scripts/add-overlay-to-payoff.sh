#!/bin/sh

cd flohmarkthelfer

IN_FILE="./data/pdfs/payoff/allpayoff.pdf"
OVERLAY_FILE="./verkaeufer-abrechnung-overlay.pdf"
OUT_FILE="./data/pdfs/payoff/allpayoff-with-overlay.pdf"

pdftk $IN_FILE background $OVERLAY_FILE output $OUT_FILE \
  ||  { echo "cannot add overlay to payoff docs"; exit 1; }
  
echo "Overlay auf Abrechnugen hinzugefügt: $OUT_FILE"  

cd ..

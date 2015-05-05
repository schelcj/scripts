#!/bin/bash

TEMP=$(tempfile)

while true; do
  dialog \
    --backtitle "Songza - Listen to Music Curated by Music Experts" \
    --title "Select a playlist to listen to" \
    --clear \
    --radiolist "Select a playlist to listen to" 20 60 24 \
      "1399111" "Downtempo Instrumentals" off \
      "1396729" "American Campfire" off \
      "1382736" "Bedroom Chillout" off \
      "1399759" "Mellow Miles" off \
      "1398535" "Margaritaville" off \
      "1472493" "Ambient Bass" off \
      "1744730" "Grandpa's Naptime" off \
      "1724146" "Lush Electronic Yoga" off \
     2> $TEMP || exit

  pyza -v $(cat $TEMP) 2>&1 | dialog --progressbox 20 100
done
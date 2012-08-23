#!/bin/bash

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

while true; do
  dialog \
    --backtitle "SomaFM: Listener Supported, Commercial Free Internet Radio" \
    --title "Select a station to listen to" --clear \
    --radiolist "Select a station to listen to" 20 40 18 \
      "doomed"               "Doomed"                 off \
      "groovesalad"          "Groove Salad"           off \
      "lush"                 "Lush"                   off \
      "suburbsofgoa"         "Suburbs of Goa"         off \
      "secretagent"          "Secret Agent"           off \
      "dronezone"            "Drone Zone"             off \
      "spacestation"         "Space Station"          off \
      "cliqhopidm"           "cliqhop idm"            off \
      "digitalis"            "Digitalis"              off \
      "sonicuniverse"        "Sonic Universe"         off \
      "bootliquor"           "Boot Liquor"            off \
      "covers"               "Covers"                 off \
      "illinoisstreetlounge" "Illinois Street Lounge" off \
      "indiepoprocks"        "indie pop rocks"        off \
      "poptron"              "PopTron"                off \
      "tagstrip"             "Tags Trip"              off \
      "beatbender"           "Beat Bender"            off \
      "missioncontrol"       "Mission Control"        off 2> $tempfile 

  rv=$?
  if [ $rv == 1 ]; then
    exit
  fi

  station="$(cat $tempfile)"
  mplayer -vo none -ao sdl http://somafm.com/startstream=${station}.pls
done

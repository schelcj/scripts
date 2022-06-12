#!/bin/bash
# ZIP="$(curl -s ipinfo.io|grep postal|awk {'print $2'}|sed 's/"//g')"
# ZIP=$(cat .zipcode)
ZIP=$(curl -s ipinfo.io|jq -r '.postal')
notify-send -u low "$(weather -f $ZIP)"

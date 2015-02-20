#!/bin/bash
ZIP="$(curl -s ipinfo.io|grep postal|awk {'print $2'}|sed 's/"//g')"
notify-send -u low "$(weather $ZIP)"

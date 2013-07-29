#!/bin/bash
IMGS=($(find ~/.wallpapers/Wallpapers/ -name '*.png'))
PAPER=${IMGS[RANDOM%${#IMGS[@]}]}

i3lock -d -i $PAPER -p win -t

#!/bin/sh

LOCK="/tmp/doing.lock"

if [ ! -e $LOCK ]; then
  touch $LOCK
  DOING=$(zenity --display=:0 --title 'What are you doing?' --entry)

  if [ $? == 0 ]; then
    doing now $DOING
  fi

  rm $LOCK
fi

#!/bin/sh

format="ps"
file=${HOME}/tmp/chair_meeting_notes.ps
page="Meetings:Weekly Chair Meeting"

zim --export Notes "$page" | htmldoc --format $format --no-toc - -f $file
lpr $file

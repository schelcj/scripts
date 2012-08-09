#!/bin/sh
note="$1"
file="$(echo "$note"|tr "[:upper:]" "[:lower:]"|tr "[:blank:]" _)"
zim --export Notes "$note" | htmldoc --format pdf --no-toc --no-title - -f ${file}.pdf
